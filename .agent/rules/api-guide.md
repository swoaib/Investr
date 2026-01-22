---
trigger: always_on
---

1. PREFER `stable` ENDPOINTS
*   **Do NOT use** `api/v3/...` or `api/v4/...` for financial statements (Income Statement, Balance Sheet, Cash Flow) unless explicitly confirmed to work. These are often treated as **Legacy** and are restricted for new/starter users.
*   **ALWAYS use** the `stable` endpoint structure: `https://financialmodelingprep.com/stable/...`

2. Dont create local fallbacks, this app is dependent on the FMP API and should therefore show the data from the API, if the data is not avaiable for some reason we should state that to the user