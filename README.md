# 📦 Inventory Management App

This is a Flutter application designed for basic inventory tracking, built using **Cloud Firestore** as the backend database. It allows users to add, view, edit, and delete inventory items, and includes advanced features for improved data analysis and filtering.

## 🚀 Getting Started

Follow these steps to set up and run the project locally.

### Prerequisites

* **Flutter SDK:** Latest stable version installed.
* **Firebase CLI:** Installed globally (`npm install -g firebase-tools`).
* **FlutterFire CLI:** Installed globally (`dart pub global activate flutterfire_cli`).
* **Android/iOS Emulator or Device** to run the app.

---

### ⚙️ 1. Project Setup and Firebase Configuration

1.  **Clone the Repository:**
    ```bash
    git clone [Your Repository URL]
    cd inclass15
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Project Linkage:**
    * Ensure you have a Firebase project created (e.g., `inventory-app-bplpriya`).
    * Run the configuration command and follow the prompts, selecting your project and target platforms (Android, iOS):
        ```bash
        flutterfire configure
        ```
    * This generates the necessary configuration files, including **`lib/firebase_options.dart`**.

4.  **Firestore Security Rules (For Testing):**
    * Go to your Firebase Console $\rightarrow$ Firestore Database $\rightarrow$ **Rules** tab.
    * Ensure your rules allow public read/write access for development:
        ```firestore
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            match /{document=**} {
              allow read, write: if true;
            }
          }
        }
        ```
    * Click **Publish**.

5.  **Create Composite Index (CRITICAL for Filtering):**
    * Go to the **Indexes** tab in your Firestore Database.
    * Click **Add Index** (Composite) for the **`items`** collection:
        | Field | Direction |
        | :--- | :--- |
        | `category` | Ascending |
        | `createdAt` | Descending |
    * Wait for the index status to change to **Enabled**.

---

### ▶️ 2. How to Run the Code

1.  **Start your emulator or plug in your device.**
2.  **Execute the Flutter Run command:**

    ```bash
    flutter run
    ```
    *The console will display interactive commands you can use while the app is running (e.g., `r` for Hot Reload, `R` for Hot Restart).*

---

## ✨ Features Implemented

### Core Functionality (CRUD)

* **View Items:** Displays a real-time list of items streamed from Firestore.
* **Add/Edit Items:** Allows creation and modification of inventory records (Name, Price, Quantity, Category).
* **Delete Items:** Items can be deleted by swiping the list tile.

### 🔎 Enhanced Feature 1: Advanced Search & Filtering

This feature enhances the usability of the main inventory list:

* **Real-time Search Bar:** Filters items by **name** client-side as the user types.
* **Category Filters:** Uses Firestore queries to filter items by **category**, utilizing the necessary composite index for efficiency.

### 📊 Enhanced Feature 2: Data Insights Dashboard

A dedicated screen accessible via the analytics icon on the home page, providing key metrics:

* **Total Unique Products:** Count of all items in the inventory.
* **Category Breakdown:** Displays the count of items belonging to each category (using `Chip` widgets).
* **Low Stock Alerts:** Lists all items with a quantity below the defined threshold (set to 10 in `FirestoreService`).

---

## 🛠️ Errors Encountered and Resolutions

This section documents key development challenges and how they were solved.

| Problem | Cause | Resolution |
| :--- | :--- | :--- |
| **"Old App" Display** | Flutter build cache retained the default counter app entry point. | Used **`flutter clean`** and manually **uninstalled the app** from the device before re-running. |
| **Indexing Error** | Firestore required a **Composite Index** to handle queries combining `where('category')` and `orderBy('createdAt')`. | Manually created the index in the **Firebase Console** (Indexes tab). |
| **Connection Stability** | Time-limited Firestore Security Rules caused transient connection errors. | Updated the **Rules** to use the permanent development setting: `allow read, write: if true;`. |