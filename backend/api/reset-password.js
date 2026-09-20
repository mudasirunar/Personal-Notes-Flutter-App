const admin = require('firebase-admin');

// Initialize Firebase Admin only once
if (!admin.apps.length) {
  let credential;

  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    try {
      const serviceAccount = typeof process.env.FIREBASE_SERVICE_ACCOUNT === 'string'
        ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
        : process.env.FIREBASE_SERVICE_ACCOUNT;
      credential = admin.credential.cert(serviceAccount);
    } catch (err) {
      console.error('Failed to parse FIREBASE_SERVICE_ACCOUNT JSON:', err);
    }
  }

  // Fallback to local serviceAccountKey.json if present during local dev
  if (!credential) {
    try {
      const localKey = require('../serviceAccountKey.json');
      credential = admin.credential.cert(localKey);
    } catch (_) {
      // Ignored if file does not exist
    }
  }

  if (credential) {
    admin.initializeApp({ credential });
  } else {
    // Default application credentials (e.g. Google Cloud)
    admin.initializeApp();
  }
}

module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed. Use POST.' });
  }

  try {
    const { email, newPassword, secretToken } = req.body || {};

    // Optional secret token protection against unauthorized API calls
    const expectedSecret = process.env.RESET_SECRET_TOKEN;
    if (expectedSecret && secretToken !== expectedSecret) {
      return res.status(403).json({ error: 'Unauthorized request token.' });
    }

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return res.status(400).json({ error: 'Valid email is required.' });
    }

    if (!newPassword || typeof newPassword !== 'string' || newPassword.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters long.' });
    }

    // Lookup user by email in Firebase Auth
    const user = await admin.auth().getUserByEmail(email.trim().toLowerCase());

    // Update password using Admin SDK
    await admin.auth().updateUser(user.uid, {
      password: newPassword,
    });

    return res.status(200).json({
      success: true,
      message: 'Password updated successfully. You can now log in.',
    });
  } catch (error) {
    console.error('Password reset error:', error);

    if (error.code === 'auth/user-not-found') {
      return res.status(404).json({ error: 'No account found with this email address.' });
    }

    return res.status(500).json({
      error: error.message || 'Failed to update password. Please try again.',
    });
  }
};
