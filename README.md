# Patient Management App

A Flutter mobile application for healthcare professionals to manage patient records, track vital signs, and conduct health assessments.

## Features

- **Patient Registration** - Register new patients with unique IDs
- **Vital Signs Tracking** - Record height, weight, and calculate BMI
- **Health Assessments** - General and overweight assessment forms
- **Patient Listing** - View all registered patients with BMI status
- **Data Sync** - Local SQLite storage with API backup
- **User Authentication** - Secure login/signup for healthcare staff

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: REST API
- **Local Database**: SQLite
- **State Management**: Provider
- **Authentication**: JWT Tokens

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/RiakJam/Patient-Management-App
   cd patient_management_app# Patient-Management-App
2. **Install dependencies**
    flutter pub get

3. Run the app
    flutter run

## Building APK
**Debug APK**
    flutter build apk --debug

**Release APK**
    flutter build apk --release

## API Configuration
    The app connects to: https://patientvisitapis.intellisoftkenya.com/api/

## Screenshots folder is added
