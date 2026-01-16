---
name: fmp_api_guidelines
description: Best practices and guidelines for using the Financial Modeling Prep (FMP) API, specifically avoiding legacy endpoints and handling the stable version correctly.
---

# Financial Modeling Prep (FMP) API Guidelines

This skill provides mandatory guidelines for interacting with the Financial Modeling Prep (FMP) API to ensure compatibility with modern subscription plans (e.g., Starter) and avoid "Legacy Endpoint" (403 Forbidden) errors.

## 1. PREFER `stable` ENDPOINTS
*   **Do NOT use** `api/v3/...` or `api/v4/...` for financial statements (Income Statement, Balance Sheet, Cash Flow) unless explicitly confirmed to work. These are often treated as **Legacy** and are restricted for new/starter users.
*   **ALWAYS use** the `stable` endpoint structure: `https://financialmodelingprep.com/stable/...`

## 2. URL STRUCTURE DIFFERENCE (Critical)
*   The `stable` endpoints typically use **Query Parameters** for the symbol, not Path Parameters.
    *   **INCORRECT (Legacy/v3 style):** `.../stable/income-statement/AAPL`
    *   **CORRECT (Stable style):** `.../stable/income-statement?symbol=AAPL`

## 3. Recommended Endpoints
When implementing financial data features, use these patterns:

| Data Type | Legacy (Avoid) | Stable (Preferred) |
| :--- | :--- | :--- |
| **Income Statement** | `api/v3/income-statement/AAPL` | `stable/income-statement?symbol=AAPL` |
| **Balance Sheet** | `api/v3/balance-sheet-statement/AAPL` | `stable/balance-sheet-statement?symbol=AAPL` |
| **Cash Flow** | `api/v3/cash-flow-statement/AAPL` | `stable/cash-flow-statement?symbol=AAPL` |
| **Key Metrics (TTM)** | `stable/key-metrics-ttm?symbol=AAPL` | `stable/key-metrics-ttm?symbol=AAPL` (Note: TTM often works, but valid data might be sparse) |
| **Ratios (TTM)** | `stable/ratios-ttm?symbol=AAPL` | `stable/ratios-ttm?symbol=AAPL` (Good source for Dividend Yield) |

## 4. Debugging Tips
*   If you receive a **403 Forbidden** with a message about "Legacy Endpoint", you are likely using `api/v3`. Switch to `stable`.
*   If you receive a **404 Not Found** on a `stable` endpoint, check your URL structure. You likely put the symbol in the path instead of `?symbol=...`.
*   Always check the [official documentation](https://site.financialmodelingprep.com/developer/docs) and look for the specific endpoint URL format if in doubt.
