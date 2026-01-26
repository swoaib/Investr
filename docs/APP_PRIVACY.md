# App Store Privacy (App Privacy)

Based on the used libraries and app functionality (as of January 2026), here is the configuration for App Store Connect > App Privacy.

## 1. Data Collection
Answer **Yes**, you collect data from this app.

## 2. Data Types
Select the following data types:

| Data Type | Category | Reason / Source |
| :--- | :--- | :--- |
| **Email Address** | Contact Info | **Feedback Form** (Optional). If a user submits feedback, they can provide an email. |
| **Customer Support** | User Content | **Feedback Form**. The content of the feedback message. |
| **Other User Content** | User Content | **Stock Alerts**. The alerts created by the user (Cloud Firestore). |
| **User ID** | Identifiers | **Firebase Auth**. The anonymous `uid` assigned to the user. |
| **Device ID** | Identifiers | **Firebase**. Used by Crashlytics and Cloud Messaging. |
| **Product Interaction** | Usage Data | **Firebase Analytics**. Screen views, button taps, DCF calculations. |
| **Crash Data** | Diagnostics | **Firebase Crashlytics**. Crash logs. |
| **Performance Data** | Diagnostics | **Firebase Analytics**. App startup time, screen rendering times. |

> **Note**: Search History is ostensibly collected (`AnalyticsService.logSearch`), but if you do not actively use this for analysis, you might ideally disable it or permit the disclosure. We recommend disclosing it as **Search History** under **Usage Data** to be safe.

---

## 3. Data Usage & Linking
For **ALL** the selected data types above, configure as follows:

1.  **Is this data used for tracking purposes?**
    *   **NO**. (Unless you explicitly enable ad tracking features or share data with brokers).
2.  **Is this data linked to the user's identity?**
    *   **YES**. (Even anonymous Firebase Auth counts as "linked" because it persists across sessions via an ID).

### Purpose of Collection

| Data Type | Purpose(s) |
| :--- | :--- |
| **Email Address** | App Functionality, Product Personalization |
| **Customer Support** | App Functionality |
| **Other User Content** | App Functionality |
| **User ID** | App Functionality, Analytics |
| **Device ID** | App Functionality, Analytics |
| **Product Interaction** | Analytics |
| **Crash Data** | App Functionality, Analytics |
| **Performance Data** | Analytics |
