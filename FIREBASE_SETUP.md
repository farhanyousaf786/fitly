# Firebase Google Sign-In Setup Guide

## ✅ What's Been Implemented

### 1. **Dependencies Added**
- ✅ `google_sign_in: ^6.2.1` added to `pubspec.yaml`

### 2. **Backend Services Updated**
- ✅ **AuthService** (`lib/services/firebase/auth_service.dart`):
  - Implemented `signInWithGoogle()` method
  - Updated `signOut()` to sign out from both Firebase and Google
  
- ✅ **AuthProvider** (`lib/providers/auth_provider.dart`):
  - Added `signInWithGoogle()` method
  - Automatic user profile creation for new Google users
  - Handles existing users seamlessly

### 3. **UI Components Updated**
- ✅ **Login Screen** (`lib/screens/auth/widgets/login_form.dart`):
  - Added "Continue with Google" button
  - Added "OR" divider
  - Proper loading states
  
- ✅ **Signup Screen** (`lib/screens/auth/signup_screen.dart`):
  - Added "Continue with Google" button
  - Added "OR" divider
  - Proper loading states

### 4. **Firebase Project**
- ✅ Created Firebase project: `fitly-ai-coach-2026`
- ✅ Generated `firebase_options.dart` with platform configurations
- ✅ Updated `main.dart` to initialize Firebase properly

---

## 📋 Required Configuration Steps

### **Step 1: Enable Authentication Methods in Firebase Console**

1. Go to [Firebase Console](https://console.firebase.google.com/project/fitly-ai-coach-2026/overview)

2. **Enable Email/Password Authentication**:
   - Click **"Authentication"** → **"Sign-in method"**
   - Enable **"Email/Password"**
   - Click **"Save"**

3. **Enable Google Sign-In**:
   - In the same **"Sign-in method"** tab
   - Click on **"Google"**
   - Toggle **"Enable"**
   - Enter your **support email** (e.g., switch2future@gmail.com)
   - Click **"Save"**

### **Step 2: Enable Firestore Database**

1. Click **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select your preferred location
5. Click **"Enable"**

### **Step 3: Configure Google Sign-In for Android**

1. **Get SHA-1 Certificate Fingerprint**:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the **SHA-1** fingerprint from the output.

2. **Add SHA-1 to Firebase**:
   - In Firebase Console → **Project Settings** → **Your apps**
   - Select your Android app
   - Scroll to **"SHA certificate fingerprints"**
   - Click **"Add fingerprint"**
   - Paste your SHA-1 fingerprint
   - Click **"Save"**

3. **Download Updated google-services.json**:
   - Download the updated `google-services.json`
   - Replace `android/app/google-services.json` with the new file

### **Step 4: Configure Google Sign-In for iOS**

1. **Add URL Scheme**:
   - Open `ios/Runner/Info.plist`
   - Add the following (replace `REVERSED_CLIENT_ID` with your actual reversed client ID from `GoogleService-Info.plist`):
   
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>YOUR_REVERSED_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

2. **Download GoogleService-Info.plist**:
   - In Firebase Console → **Project Settings** → **Your apps**
   - Select your iOS app
   - Download `GoogleService-Info.plist`
   - Add it to `ios/Runner/` directory in Xcode

### **Step 5: Optional - Add Google Logo Asset**

To display the Google logo instead of a generic icon:

1. Download the official Google logo
2. Save it as `assets/images/google_logo.png`
3. Update `pubspec.yaml`:
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/images/google_logo.png
   ```

---

## 🚀 Testing

Once configuration is complete:

```bash
flutter clean
flutter pub get
flutter run
```

### Test Scenarios:
1. ✅ **Email Sign-Up**: Create account with email/password
2. ✅ **Email Sign-In**: Login with email/password
3. ✅ **Google Sign-In** (New User): Sign in with Google (creates profile automatically)
4. ✅ **Google Sign-In** (Existing User): Sign in with Google (loads existing profile)
5. ✅ **Sign Out**: Properly signs out from both Firebase and Google

---

## 📝 Notes

- **Google Sign-In Button**: Currently uses a fallback icon. Add the Google logo asset for the official branding.
- **User Profiles**: Google users get auto-created profiles with their Google display name and photo.
- **Error Handling**: All authentication errors are properly caught and displayed to users.
- **Loading States**: Both buttons show loading indicators during authentication.

---

## 🔗 Useful Links

- [Firebase Console](https://console.firebase.google.com/project/fitly-ai-coach-2026/overview)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
