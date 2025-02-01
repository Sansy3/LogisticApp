# Logistics Platform App

## 🚚 Overview

The Logistics Platform App connects **drivers** and **dispatchers**, providing a seamless and efficient solution for **shipment management**. The app leverages **Firebase Authentication**, **Firestore**, and **SwiftUI/UIKit** to deliver a smooth user experience. Key features include:

- **Role-based dashboards**
- **Real-time location tracking**
- **Shipment management**
- **Communication through chat**
- **Real-time driver tracking on the map**

## 🌟 Features

- **User Authentication**: 
  - Sign in and sign up with Firebase Authentication.
  - Users are authenticated and their details are stored in Firestore.

- **Role-Based Dashboards**: 
  - **Driver Dashboard**: Allows drivers to manage assigned shipments, track their location in real-time, and update their status.
  - **Dispatcher Dashboard**: Allows dispatchers to manage available shipments, assign drivers, and monitor all drivers' locations on the map.

- **Real-Time Location Updates**: 
  - Drivers' locations are updated and uploaded to Firestore, where dispatchers can monitor them.

- **Shipment Management**: 
  - Dispatchers can assign drivers to shipments. Drivers can view and manage their assigned shipments.

- **Chat Feature**: 
  - Enables real-time communication between drivers and dispatchers.
  - Messages are stored in Firestore under a single conversation document for smooth communication among all involved users.

- **External Data**: 
  - Shipment data is fetched from an external API for testing purposes.

- **Driver Tracking on Map**: 
  - Dispatchers can view all drivers' locations on the map in real-time, enhancing coordination and decision-making.

---

## 📊 Database Structure

### Firestore Collections

- **`users`**: Stores user profiles with fields like:
  - `name`
  - `email`
  - `role` (driver or dispatcher)
  - `truckDetails` (for drivers)
  
- **`loads`**: Stores available shipments with fields like:
  - `origin`
  - `destination`
  - `weight`
  - `truckType`
  - `status`
  
- **`locations`**: Tracks real-time driver locations, including:
  - `latitude`
  - `longitude`
  - `timestamp`
  
- **`conversations`**: Stores messages between users (drivers and dispatchers). 
  - All users involved in a conversation share a single document for communication.

---

## 🔑 Authentication Flow

1. **Sign In / Sign Up**: 
   - Users sign in or sign up using **Firebase Authentication**.
   
2. **User Profile**: 
   - During sign-up, users provide additional details (like name and role) which are stored in the `users` collection in Firestore.

3. **Role-Based Navigation**: 
   - After successful authentication, the app checks the user’s role and navigates them to the appropriate dashboard:
     - **DriverTabBarController** (for drivers)
     - **CustomTabBarController** (for dispatchers)

---

## 🗺️ Real-Time Features

- **Location Tracking**: 
  - **LocationManager** tracks the driver’s location and uploads it to Firestore in the `locations` collection for real-time updates.

- **MapView**: 
  - **MapVC** displays a map with real-time updates of drivers' locations using annotations and callouts.
  - Dispatchers can see the positions of all drivers on the map, enabling more efficient resource management.

---

## 🔐 Firebase Security Rules

- **Role-Based Access**: 
  - Enforces role-based access control, ensuring that **drivers** and **dispatchers** can only access their appropriate data.

- **Data Validation**: 
  - Firebase security rules validate data writes, restricting sensitive fields (like `assignedDriverId`) and ensuring that only authenticated users can read/write data.

---

## ⚠️ Error Handling

- The app uses an **`AppError` enum** for consistent error handling.
- Alerts are triggered for errors, such as:
  - Invalid credentials
  - Firestore write failures
  - Missing data
  
---

💻 Tech Stack
Frontend: Swift, UIKit, SwiftUI
Backend: Firebase Authentication, Firestore
Real-Time Data: Firestore real-time listeners

