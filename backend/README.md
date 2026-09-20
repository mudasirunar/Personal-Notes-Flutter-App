# Personal Notes Backend (Vercel Serverless Function)

A secure serverless function that uses the **Firebase Admin SDK** to update user passwords after 6-digit OTP verification.

---

## 🚀 How to Deploy to Vercel (100% Free, No Credit Card)

### Step 1: Download your Firebase Service Account Key
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select project: **`personal-notes-app-30e1a`**.
3. Click the **Gear icon ⚙️ (Project settings)** ➔ **Service accounts** tab.
4. Click **Generate new private key** ➔ downloads a `.json` file.
5. Open the `.json` file in a text editor and copy all text.

### Step 2: Deploy to Vercel
1. Go to [vercel.com](https://vercel.com/) and log in (with your GitHub account).
2. Click **Add New...** ➔ **Project**.
3. Import your GitHub repository (`Personal-Notes-Flutter-App`).
4. Set **Root Directory** to `backend`.
5. Under **Environment Variables**, add:
   - **Key**: `FIREBASE_SERVICE_ACCOUNT`
   - **Value**: Paste the entire JSON string copied from Step 1.
   - *(Optional)* **Key**: `RESET_SECRET_TOKEN`, **Value**: `personal_notes_secret_token_2026`
6. Click **Deploy**!

### Step 3: Copy Your Production URL
Once deployed, Vercel gives you a free production domain, for example:
`https://personal-notes-backend-xyz.vercel.app`

Your endpoint will be:
`https://personal-notes-backend-xyz.vercel.app/api/reset-password`

Paste this URL in Flutter's `lib/core/constants/api_config.dart`!
