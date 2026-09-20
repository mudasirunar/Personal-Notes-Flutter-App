const https = require('https');

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
    const { email, otpCode, secretToken } = req.body || {};

    // Validate security token
    const expectedSecret = process.env.RESET_SECRET_TOKEN;
    if (expectedSecret && secretToken !== expectedSecret) {
      return res.status(403).json({ error: 'Unauthorized request token.' });
    }

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return res.status(400).json({ error: 'Valid email is required.' });
    }

    if (!otpCode || typeof otpCode !== 'string' || otpCode.length !== 6) {
      return res.status(400).json({ error: 'Valid 6-digit OTP is required.' });
    }

    const apiKey = process.env.BREVO_API_KEY;
    if (!apiKey) {
      return res.status(500).json({
        error: 'BREVO_API_KEY environment variable is not configured on Vercel.',
      });
    }

    const senderEmail = process.env.BREVO_SENDER_EMAIL || 'unarmudasir@gmail.com';
    const senderName = 'Personal Notes Support';
    const replyToEmail = 'support@personalnotes.app';

    // HTML Email Template with Indigo Gradient and Modern Styling
    const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Password Reset Verification Code</title>
</head>
<body style="margin: 0; padding: 0; background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #f8fafc; padding: 40px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" style="max-width: 520px; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05); border: 1px solid #e2e8f0;">
          <tr>
            <td style="background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%); padding: 32px 24px; text-align: center;">
              <div style="width: 54px; height: 54px; background-color: rgba(255, 255, 255, 0.2); border-radius: 14px; margin: 0 auto 12px; display: flex; align-items: center; justify-content: center; line-height: 54px; font-size: 26px;">
                🔐
              </div>
              <h1 style="margin: 0; color: #ffffff; font-size: 22px; font-weight: 700; letter-spacing: -0.5px;">
                Personal Notes Security
              </h1>
              <p style="margin: 6px 0 0 0; color: rgba(255, 255, 255, 0.85); font-size: 14px;">
                Password Reset Verification
              </p>
            </td>
          </tr>
          <tr>
            <td style="padding: 32px 28px;">
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td style="padding-bottom: 16px;">
                    <p style="margin: 0; font-size: 15px; color: #334155; line-height: 1.6;">Hello,</p>
                    <p style="margin: 8px 0 0 0; font-size: 15px; color: #334155; line-height: 1.6;">
                      We received a request to reset your password for your <strong>${email}</strong> account. Use the verification code below to proceed:
                    </p>
                  </td>
                </tr>
                <tr>
                  <td align="center" style="padding: 24px 0;">
                    <div style="display: inline-block; background-color: #f1f5f9; border: 2px dashed #cbd5e1; border-radius: 12px; padding: 16px 32px;">
                      <span style="font-family: 'Courier New', Courier, monospace; font-size: 36px; font-weight: 800; letter-spacing: 10px; color: #4f46e5;">
                        ${otpCode}
                      </span>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td style="padding-top: 8px;">
                    <p style="margin: 0; font-size: 13px; color: #64748b; line-height: 1.5; text-align: center;">
                      ⏱️ This verification code is valid for <strong>10 minutes</strong>.
                    </p>
                    <p style="margin: 12px 0 0 0; font-size: 13px; color: #94a3b8; line-height: 1.5; text-align: center;">
                      If you did not request a password reset, you can safely ignore this email. Your account remains secure.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="background-color: #f8fafc; padding: 18px 32px; border-top: 1px solid #f1f5f9; text-align: center;">
              <p style="margin: 0; font-size: 12px; color: #94a3b8;">
                © 2026 Personal Notes App. Automated Security Email.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;

    const payload = JSON.stringify({
      sender: {
        name: senderName,
        email: senderEmail,
      },
      replyTo: {
        name: senderName,
        email: replyToEmail,
      },
      to: [{ email: email.trim().toLowerCase() }],
      subject: 'Your Password Reset Code - Personal Notes',
      htmlContent: htmlContent,
    });

    const options = {
      hostname: 'api.brevo.com',
      port: 443,
      path: '/v3/smtp/email',
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'api-key': apiKey,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
      },
    };

    const response = await new Promise((resolve, reject) => {
      const brevoReq = https.request(options, (brevoRes) => {
        let data = '';
        brevoRes.on('data', (chunk) => (data += chunk));
        brevoRes.on('end', () => {
          resolve({ statusCode: brevoRes.statusCode, body: data });
        });
      });

      brevoReq.on('error', (err) => reject(err));
      brevoReq.write(payload);
      brevoReq.end();
    });

    if (response.statusCode === 200 || response.statusCode === 201) {
      return res.status(200).json({
        success: true,
        message: 'OTP verification code sent successfully.',
      });
    } else {
      let errMsg = 'Failed to send verification email via Brevo.';
      try {
        const parsed = JSON.parse(response.body);
        errMsg = parsed.message || errMsg;
      } catch (_) {}
      return res.status(response.statusCode).json({ error: errMsg });
    }
  } catch (error) {
    console.error('Send OTP error:', error);
    return res.status(500).json({
      error: error.message || 'Internal server error sending OTP.',
    });
  }
};
