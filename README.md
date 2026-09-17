 #  Smart Expense Tracker

A modern **Personal Expense and Budget Management App** built with **Flutter and Firebase**. The application helps users securely manage their daily expenses, set monthly budgets, analyze spending patterns, and export their financial data.

---

##  Project Overview

**Smart Expense Tracker** is a mobile expense management application designed to make personal financial tracking simple, organized, and accessible.

Users can create an account, securely sign in, record and manage expenses, set monthly budgets, analyze spending by category and month, switch between light and dark themes, and export their financial records as PDF or CSV files.

The application uses **Firebase Authentication** for user authentication and **Cloud Firestore** for storing user-specific financial data.

---

##  Features

###  User Authentication

* User registration and login
* Firebase Authentication
* Email verification
* Forgot password functionality
* Persistent authentication state
* Secure logout
* Protected application screens for authenticated users
* User-specific data linked using Firebase UID

###  Expense Management

Users can:

* Add new expenses
* Edit existing expenses
* Delete expenses
* View all recorded expenses
* Enter expense amount and description
* Select expense categories
* Select expense dates
* View expense information in an organized interface

#### Available Categories

*  Food & Dining
*  Transportation
*  Utilities & Bills
*  Housing
*  Entertainment & Leisure
*  Shopping
*  Subscriptions
*  Health & Medical
*  Other / Miscellaneous

###  Analytics & Reports

The application provides visual financial insights, including:

* Total spending
* Current-month spending
* Category-wise spending
* Monthly spending analysis
* Spending charts
* Expense summaries

These features help users understand their spending patterns.

###  Monthly Budget Management

Users can:

* Set a monthly budget
* View their current monthly budget
* Track spending against the budget
* Store budget information separately for each month
* Manage budget data using Firebase Firestore

###  Light & Dark Mode

The application supports dynamic theme switching.

* Light mode
* Dark mode
* Persistent theme preference
* Theme preference stored locally
* Smooth animated theme transitions

###  Data Export

Users can export their expense information in:

* **PDF format**
* **CSV format**

Exported files can be saved to the device for personal records and reporting.

###  Profile & Account Management

The profile section provides:

* Account management
* Default user avatar
* Theme settings
* Data export and reports
* Logout
* Account deletion

The application does not require users to upload a profile picture.

---

##  Technologies Used

 Technology                   Purpose                                         
 --------------------------- ----------------------------------------------- 
 **Flutter**                 | Cross-platform application development          
 **Dart**                    | Programming language                            
 **Firebase Authentication** | User registration, login and account management 
 **Cloud Firestore**         | Cloud database                                  
 **Provider**                | State management                                
 **SharedPreferences**       | Local theme preference storage                  
 **Material 3**              | User interface design                           
 **Intl**                    | Date and number formatting                      
 **FL Chart**                | Analytics and data visualization                
 **PDF**                     | PDF report generation                           
 **CSV**                     | CSV data export                                 

---

##  Application Architecture

The application follows a structured architecture that separates UI, state management, business logic, models, and Firebase services.

```text
lib/
│
├── main.dart
│
├── models/
│   ├── expense_model.dart
│   ├── budget.dart
│   └── expense_model.dart
│    
├── providers/
│   ├── auth_provider.dart
│   ├── expense_provider.dart
│   └── theme_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── email_verification_screen.dart
│   │
│   ├── expenses/
│   │   ├── add_expense_screen.dart
│   │   ├── edit_expense_screen.dart
│   │   └── expense_list_screen.dart
│   │
│   ├── analytics/
│   │   └── analytics_screen.dart
│   │
│   ├── budget/
│   │   └── budget_screen.dart
│   │
│   ├── reports/
│   │   └── data_export_screen.dart
│   │
│   ├── profile/
│   │   └── profile_screen.dart
│   │
│   └── main_screen.dart
│
└── services/
    ├── auth_service.dart
    ├── expense_service.dart
    ├── budget_service.dart
    ├── user_service.dart
    ├── theme_service.dart
    └── export_service.dart
```

### Architecture Flow

```text
User Interface
      │
      ▼
Provider State Management
      │
      ▼
Service Layer
      │
      ├──────────────► Firebase Authentication
      │
      └──────────────► Cloud Firestore
```

This structure keeps application logic outside the UI widgets and makes the application easier to maintain and extend.

---

##  Firebase Structure

The application uses Firebase services for authentication and cloud data storage.

### Firebase Authentication

Firebase Authentication manages:

* User registration
* Login
* Logout
* Email verification
* Password reset
* Account deletion

### Cloud Firestore

User-specific information is associated with the authenticated user's Firebase UID.

A simplified database structure is:

```text
users/
  └── {uid}/
       ├── firstName
       ├── lastName
       ├── gender
       └── ...

expenses/
  └── {expenseId}/
       ├── uid
       ├── amount
       ├── category
       ├── description
       ├── date
       └── createdAt

budgets/
  └── {uid}/
       └── monthly/
            └── {YYYY-MM}/
                 ├── amount
                 ├── month
                 └── updatedAt
```

> The exact Firestore structure may vary depending on the current Firebase service implementation.

---

##  Security & Data Isolation

The application is designed around authenticated user access.

Each user's expense and budget data is associated with their Firebase Authentication UID.

This ensures that application data can be scoped to the currently authenticated user rather than treating all expenses as belonging to one global account.

Firestore Security Rules should be configured so that authenticated users can only access their own data.

---

##  Getting Started

### Prerequisites

Before running the project, install:

* Flutter SDK
* Dart SDK
* Android Studio or another Android development environment
* Android SDK
* Git
* A Firebase project

Verify Flutter installation:

```bash
flutter doctor
```

---

##  Installation

### 1. Clone the Repository

```bash
git clone <https://github.com/Sarojshrestha-code/smart_expense_tracker>
```

Navigate into the project:

```bash
cd smart_expense_tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Configure the application with your Firebase project using FlutterFire CLI.

```bash
flutterfire configure
```

This generates the Firebase configuration required by the Flutter application.

Make sure Firebase Authentication and Cloud Firestore are enabled in your Firebase project.

### 4. Run the Application

Connect an Android device or start an Android emulator.

Then run:

```bash
flutter run
```

You can also run the project on Chrome during development:

```bash
flutter run -d chrome
```

---

##  Firebase Configuration

The project uses FlutterFire configuration.

Important Firebase-related files include:

```text
firebase.json
lib/firebase_options.dart
```

For security, Firebase credentials and other sensitive configuration should be handled appropriately before publishing the repository publicly.

Do not commit private API keys, service-account files, passwords, or other secrets.

---

##  Main Application Screens

The application contains the following major sections:

### Authentication

```text
Login
   │
   ├── Forgot Password
   │
   └── Register
          │
          ▼
     Email Verification
          │
          ▼
         Home
```

### Main Navigation

```text
┌──────────┬──────────┬───────────┬────────┬─────────┐
│   Home   │ Expenses │ Analytics │ Budget │ Profile │
└──────────┴──────────┴───────────┴────────┴─────────┘
```

### Home

The dashboard provides an overview of the user's financial activity, including:

* Personalized welcome message
* Current-month spending
* Total spending
* Budget information
* Quick actions
* Recent expense information

### Expenses

Users can manage their expense records from one place.

```text
Add Expense
     │
     ▼
Expense List
     │
 ┌───┴────┐
 ▼        ▼
Edit     Delete
```

### Analytics

Provides visual representations of spending by category and month.

### Budget

Allows users to create and manage their monthly spending limit.

### Profile

Provides account and application settings, including theme management, export tools, logout, and account deletion.

---

##  User Interface

The application uses **Material 3** design principles to provide a modern Flutter interface.

Key UI characteristics include:

* Material 3 components
* Responsive layouts
* Bottom navigation
* Cards and organized sections
* Category icons
* Light/Dark themes
* Animated theme transitions
* Confirmation dialogs for destructive actions
* Mobile-friendly layouts

---

##  State Management

The application uses **Provider** for state management.

Current providers include:

```text
AuthProvider
ExpenseProvider
ThemeProvider
```

### AuthProvider

Responsible for authentication-related application state.

```text
Login
Register
Logout
Email Verification
Authentication State
```

### ExpenseProvider

Responsible for expense-related state and operations.

```text
Load Expenses
Add Expense
Update Expense
Delete Expense
Refresh Expense Data
```

### ThemeProvider

Responsible for:

```text
Light Mode
Dark Mode
Theme Switching
Theme Persistence
```

Using Provider keeps business and state logic separate from UI widgets.

---

##  Expense Workflow

```text
User
 │
 ▼
Add Expense
 │
 ├── Amount
 ├── Category
 ├── Description
 └── Date
 │
 ▼
ExpenseProvider
 │
 ▼
ExpenseService
 │
 ▼
Cloud Firestore
 │
 ▼
Updated Expense List
 │
 ├── Analytics
 ├── Home Dashboard
 └── Reports
```

---

##  Data Export Workflow

```text
Expense Data
     │
     ▼
Export Service
     │
     ├──────────────┐
     ▼              ▼
    PDF            CSV
     │              │
     └──────┬───────┘
            ▼
      Device Storage
```

Users can generate reports from their stored expense data and save them to their device.

---

##  Testing & Code Quality

Run Flutter static analysis using:

```bash
flutter analyze
```

Run automated tests using:

```bash
flutter test
```

For a release build:

```bash
flutter build apk --release
```

Before creating a release, it is recommended to verify:

* Authentication flow
* Email verification
* Password reset
* Expense CRUD
* Budget management
* Analytics
* Theme switching
* Data export
* Logout
* Account deletion
* Firestore security rules

---

##  Git Workflow

Typical development workflow:

```bash
git status
```

Stage changes:

```bash
git add .
```

Create a commit:

```bash
git commit -m "Update expense management and state management"
```

Push changes:

```bash
git push origin main
```

---

##  Future Enhancements

Possible future improvements include:

*  Budget limit notifications
*  Advanced date-range filtering
*  Expense search and filtering
*  More detailed financial analytics
*  Automated cloud backup
*  Improved tablet responsiveness
*  More report formats
*  Custom analytics dashboards
*  Recurring expenses
*  Multiple currency support
*  AI-powered spending insights
*  Financial goals and savings tracking

---

##  Academic Project

This application was developed as an academic software project demonstrating practical implementation of:

* Mobile application development
* Flutter and Dart
* Firebase Authentication
* Cloud Firestore
* State management
* CRUD operations
* Data visualization
* Local data persistence
* File generation and export
* Responsive UI design
* Software architecture

The project demonstrates how a real-world personal finance application can combine cloud services, state management, analytics, and user-focused interface design.

---

##  Project Status

**Status:**  Active Development

Core functionality currently includes:

* [x] User registration
* [x] User login
* [x] Email verification
* [x] Password reset
* [x] Logout
* [x] Expense creation
* [x] Expense editing
* [x] Expense deletion
* [x] Expense categories
* [x] Monthly budgets
* [x] Spending analytics
* [x] Light/Dark mode
* [x] Provider state management
* [x] PDF export
* [x] CSV export
* [x] Account management

---

##  Author

**Saroj Shrestha**

Bachelor of Information Technology (BIT)
NCMT college
Nepal

---

## 📄 License

This project is developed for educational and academic purposes.

If you intend to reuse, modify, or distribute this project, please contact the author for permission.

---

##  Acknowledgements

This project uses the following technologies and services:

* Flutter
* Dart
* Firebase
* Cloud Firestore
* Firebase Authentication
* Provider
* Material 3

---

##  Contact

For questions, suggestions, or collaboration regarding this project, please contact the project author through the contact information provided in the GitHub profile.

---

**Smart Expense Tracker — Manage your expenses. Understand your spending. Take control of your budget.**
