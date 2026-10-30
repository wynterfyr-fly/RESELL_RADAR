const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const axios = require("axios");

const app = express();

app.use(cors({ origin: true }));

// ======================================================
// EBAY OAUTH TEST
// ======================================================

app.get("/ebay-test", async (req, res) => {
  try {
    const clientId = process.env.EBAY_CLIENT_ID;
    const clientSecret = process.env.EBAY_CLIENT_SECRET;

    const auth = Buffer.from(
      `${clientId}:${clientSecret}`
    ).toString("base64");

    const response = await axios.post(
      "https://api.ebay.com/identity/v1/oauth2/token",
      "grant_type=client_credentials&scope=https://api.ebay.com/oauth/api_scope",
      {
        headers: {
          Authorization: `Basic ${auth}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    res.json({
      success: true,
      tokenReceived: !!response.data.access_token,
      expiresIn: response.data.expires_in,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error:
        error.response?.data ||
        error.message,
    });
  }
});
// ======================================================
// EBAY TOKEN HELPER
// ======================================================

async function getEbayAccessToken() {
  const clientId = process.env.EBAY_CLIENT_ID;
  const clientSecret = process.env.EBAY_CLIENT_SECRET;

  const auth = Buffer.from(
    `${clientId}:${clientSecret}`
  ).toString("base64");

  const response = await axios.post(
    "https://api.ebay.com/identity/v1/oauth2/token",
    "grant_type=client_credentials&scope=https://api.ebay.com/oauth/api_scope",
    {
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
    }
  );

  return response.data.access_token;
}

// ======================================================
// EBAY SPECIFIC LISTING STATUS LOOKUP
// ======================================================

app.get("/ebay-item-status/:itemId", async (req, res) => {
  try {
    const itemId = req.params.itemId;

    if (!itemId) {
      return res.status(400).json({
        success: false,
        message: "Missing eBay item ID",
      });
    }

    const token = await getEbayAccessToken();

    try {
      const response = await axios.get(
        `https://api.ebay.com/buy/browse/v1/item/${encodeURIComponent(itemId)}`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "X-EBAY-C-MARKETPLACE-ID": "EBAY_US",
          },
        }
      );

      const item = response.data;

      const currentPrice =
        Number(item.price?.value) || 0;

      return res.json({
        success: true,
        itemId: item.itemId || itemId,
        isAvailable: true,
        currentPrice,
        title: item.title || "",
        marketplaceUrl: item.itemWebUrl || "",
      });
    } catch (error) {
      if (error.response?.status === 404) {
        return res.json({
          success: true,
          itemId,
          isAvailable: false,
          currentPrice: 0,
        });
      }

      throw error;
    }
  } catch (error) {
    console.error(
      "eBay item status lookup error:",
      error.response?.data || error.message
    );

    return res.status(500).json({
      success: false,
      message: "Unable to check eBay item status",
    });
  }
});

// ======================================================
// EBAY LIVE BARCODE LOOKUP
// ======================================================

app.get("/ebay-lookup/:barcode", async (req, res) => {
  try {
    const barcode = req.params.barcode;

    const token = await getEbayAccessToken();

    let response = await axios.get(
      "https://api.ebay.com/buy/browse/v1/item_summary/search",
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "X-EBAY-C-MARKETPLACE-ID": "EBAY_US",
        },
        params: {
          gtin: barcode,
          limit: 25,
        },
      }
    );
    
    let items =
      response.data.itemSummaries || [];
    
    // If GTIN lookup finds nothing, fall back to keyword search using the barcode.
    if (items.length === 0) {
      response = await axios.get(
        "https://api.ebay.com/buy/browse/v1/item_summary/search",
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "X-EBAY-C-MARKETPLACE-ID": "EBAY_US",
          },
          params: {
            q: barcode,
            limit: 25,
          },
        }
      );
    
      items =
        response.data.itemSummaries || [];
    }
    
    if (items.length === 0) {
      return res.json({
        success: false,
        barcode: barcode,
        message: "No eBay results found",
      });
    }

    if (items.length > 0 && items.length < 5) {
      const titleSearch =
        items[0].title;
    
      const titleResponse =
        await axios.get(
          'https://api.ebay.com/buy/browse/v1/item_summary/search',
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
            params: {
              q: titleSearch,
              limit: 25,
            },
          },
        );
    
      const titleItems =
        titleResponse.data.itemSummaries || [];
    
      const existingIds = new Set(
        items.map((item) => item.itemId),
      );
    
      for (const titleItem of titleItems) {
        if (!existingIds.has(titleItem.itemId)) {
          items.push(titleItem);
        }
      }
    }
    const prices = items
  .map((item) =>
    Number(item.price?.value)
  )
  .filter((price) =>
    !Number.isNaN(price) && price > 0
  );

const sortedPrices =
  [...prices].sort((a, b) => a - b);

let filteredPrices =
  [...sortedPrices];

if (sortedPrices.length >= 5) {
  const lowerIndex =
    Math.floor(sortedPrices.length * 0.10);

  const upperIndex =
    Math.ceil(sortedPrices.length * 0.90);

  filteredPrices =
    sortedPrices.slice(
      lowerIndex,
      upperIndex,
    );
}

const lowestPrice =
  filteredPrices.length > 0
    ? filteredPrices[0]
    : null;

const averagePrice =
  filteredPrices.length > 0
    ? filteredPrices.reduce((a, b) => a + b, 0) /
        filteredPrices.length
    : null;

const medianPrice =
  filteredPrices.length > 0
    ? filteredPrices.length % 2 === 1
      ? filteredPrices[
          Math.floor(filteredPrices.length / 2)
        ]
      : (
          filteredPrices[
            filteredPrices.length / 2 - 1
          ] +
          filteredPrices[
            filteredPrices.length / 2
          ]
        ) / 2
    : null;

const highestPrice =
  filteredPrices.length > 0
    ? filteredPrices[
        filteredPrices.length - 1
      ]
    : null;

const priceSpread =
  lowestPrice !== null &&
  highestPrice !== null
    ? highestPrice - lowestPrice
    : null;
    const firstItem =
      items[0];

    res.json({
      success: true,
      barcode: barcode,
      source: "eBay",
      product: {
        name:
          firstItem.title || "eBay Product",

          itemId:
          firstItem.itemId || "",
          
          image:
          firstItem.image?.imageUrl ||
          firstItem.thumbnailImages?.[0]?.imageUrl ||
          firstItem.additionalImages?.[0]?.imageUrl ||
          "",

        marketplaceUrl:
          firstItem.itemWebUrl || "https://www.ebay.com",

          amazonUrl:
  `https://www.amazon.com/s?k=${encodeURIComponent(barcode)}&tag=resellradar-20`,

        currency:
          firstItem.price?.currency || "USD",

          lowestPrice:
          lowestPrice,
        
        averagePrice:
          averagePrice,
        
        medianPrice:
          medianPrice,

          highestPrice:
          highestPrice,
        
        priceSpread:
          priceSpread,

        marketPrice:
          medianPrice || averagePrice || lowestPrice || 0,
        
          resultCount:
          items.length,
        
        rawPrices:
          prices,
        
        filteredPrices:
          filteredPrices,
        
        profitPotential:
          "+0%",
      },
      rawItems:
        items.slice(0, 5),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error:
        error.response?.data ||
        error.message,
    });
  }
});

// ======================================================
// EBAY LIVE TEXT SEARCH
// ======================================================

app.get("/ebay-search/:query", async (req, res) => {
  try {
    const query = req.params.query;

    const token = await getEbayAccessToken();

    const response = await axios.get(
      "https://api.ebay.com/buy/browse/v1/item_summary/search",
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "X-EBAY-C-MARKETPLACE-ID": "EBAY_US",
        },
        params: {
          q: query,
          limit: 20,
        },
      }
    );

    const items = response.data.itemSummaries || [];

    if (items.length === 0) {
      return res.json({
        success: false,
        query,
        message: "No eBay search results found",
        products: [],
      });
    }

    const products = items.map((item) => {
      const price = Number(item.price?.value) || 0;

      return {
        name: item.title || "eBay Product",
        itemId: item.itemId || "",
        image:
          item.image?.imageUrl ||
          item.thumbnailImages?.[0]?.imageUrl ||
          item.additionalImages?.[0]?.imageUrl ||
          "",
        marketplaceUrl: item.itemWebUrl || "https://www.ebay.com",
        amazonUrl:
          `https://www.amazon.com/s?k=${encodeURIComponent(item.title || query)}&tag=resellradar-20`,
        currency: item.price?.currency || "USD",
        marketPrice: price,
        lowestPrice: price,
        averagePrice: price,
        medianPrice: price,
        highestPrice: price,
        priceSpread: 0,
        resultCount: items.length,
        rawItems: items.slice(0, 5),
        rawPrices: [price],
        filteredPrices: [price],
        profitPotential: "+0%",
      };
    });

    res.json({
      success: true,
      query,
      source: "eBay",
      products,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.response?.data || error.message,
    });
  }
});

// =====================================================
// AMAZON BARCODE LOOKUP
// Phase 1: Search-link mode
// Future: Replace with Product Advertising API data
// =====================================================

app.get("/amazon-lookup/:barcode", async (req, res) => {
  try {
    const barcode = req.params.barcode;
    const associateTag = "resellradar-20";

    const amazonSearchUrl =
      `https://www.amazon.com/s?k=${encodeURIComponent(barcode)}&tag=${associateTag}`;

    res.json({
      success: true,
      source: "Amazon",
      barcode,
      product: {
        title: "Amazon Search Available",
        price: null,
        displayPrice: "Search Amazon",
        availability: "Open Amazon to view current offers",
        rating: null,
        reviewCount: null,
        image: "",
        amazonUrl: amazonSearchUrl,
        marketplaceUrl: amazonSearchUrl,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.response?.data || error.message,
    });
  }
});

// ======================================================
// TEST ROUTE
// ======================================================

app.get("/hello", (req, res) => {

  res.json({
    success: true,
    message: "Resell Radar backend is live!",
    timestamp: Date.now(),
  });

});

// ======================================================
// TEST BARCODE LOOKUP
// ======================================================

app.get("/lookup/:barcode", (req, res) => {

  const barcode = req.params.barcode;

  const mockProducts = {

    "711719541028": {
      name: "PlayStation 5",
      marketPrice: 420,
      lowestPrice: 375,
      profitPotential: "+18%",
      marketplace: "eBay",
    },

    "820650850149": {
      name: "Pokemon Booster Box",
      marketPrice: 240,
      lowestPrice: 180,
      profitPotential: "+41%",
      marketplace: "TCGPlayer",
    },

    "889698624552": {
      name: "Star Wars Ultimate Grogu",
      marketPrice: 550,
      lowestPrice: 430,
      profitPotential: "+22%",
      marketplace: "eBay",
    },

  };

  const product =
      mockProducts[barcode];

  if (product) {

    res.json({
      success: true,
      barcode: barcode,
      product: product,
    });

  } else {

    res.json({
      success: false,
      barcode: barcode,
      message: "Unknown product",
    });
  }

});

// ======================================================
// EXPORT CLOUD FUNCTION
// ======================================================

exports.api =
    functions.https.onRequest(app);