// =======================================================================================================================================
// Email Service: Resend Integration for Authentication Emails
// =======================================================================================================================================
// Purpose: Handles sending verification emails and password reset emails using Resend API
// =======================================================================================================================================

const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);

// Email templates
const emailTemplates = {
  // Email verification template
  verification: (verificationUrl, displayName) => ({
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verify Your Email - Questie</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
          .container { max-width: 600px; margin: 0 auto; background: white; }
          .header { padding: 40px 30px; text-align: center; background: white; }
          .content { padding: 30px; }
          .button { display: inline-block; padding: 15px 30px; background: #2563eb; color: white; text-decoration: none; border-radius: 8px; font-weight: 600; margin: 20px 0; }
          .footer { padding: 30px; text-align: center; color: #666; font-size: 14px; background: #f8f9fa; }
          h1 { color: #333; margin: 0 0 20px 0; font-size: 28px; }
          p { color: #555; line-height: 1.6; margin: 0 0 15px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome to Questie!</h1>
          </div>
          <div class="content">
            <p>Hi ${displayName || 'there'},</p>
            <p>Thanks for signing up for Questie! To complete your registration and start your quest adventure, please verify your email address.</p>
            <p style="text-align: center;">
              <a href="${verificationUrl}" class="button">Verify Email Address</a>
            </p>
            <p>This verification link will expire in 24 hours for security reasons.</p>
            <p>If you didn't create a Questie account, you can safely ignore this email.</p>
          </div>
          <div class="footer">
            <p>This email was sent by Questie. If you have questions, please contact support.</p>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
      Welcome to Questie!
      
      Hi ${displayName || 'there'},
      
      Thanks for signing up for Questie! To complete your registration and start your quest adventure, please verify your email address by clicking the link below:
      
      ${verificationUrl}
      
      This verification link will expire in 24 hours for security reasons.
      
      If you didn't create a Questie account, you can safely ignore this email.
      
      Best regards,
      The Questie Team
    `
  }),

  // Password reset template
  passwordReset: (resetUrl, displayName) => ({
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Your Password - Questie</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
          .container { max-width: 600px; margin: 0 auto; background: white; }
          .header { padding: 40px 30px; text-align: center; background: white; }
          .content { padding: 30px; }
          .button { display: inline-block; padding: 15px 30px; background: #2563eb; color: white; text-decoration: none; border-radius: 8px; font-weight: 600; margin: 20px 0; }
          .footer { padding: 30px; text-align: center; color: #666; font-size: 14px; background: #f8f9fa; }
          h1 { color: #333; margin: 0 0 20px 0; font-size: 28px; }
          p { color: #555; line-height: 1.6; margin: 0 0 15px 0; }
          .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Reset Your Password</h1>
          </div>
          <div class="content">
            <p>Hi ${displayName || 'there'},</p>
            <p>We received a request to reset your Questie account password. Click the button below to create a new password:</p>
            <p style="text-align: center;">
              <a href="${resetUrl}" class="button">Reset Password</a>
            </p>
            <div class="warning">
              <p><strong>Security Notice:</strong> This password reset link will expire in 1 hour for your security.</p>
            </div>
            <p>If you didn't request a password reset, you can safely ignore this email. Your password will remain unchanged.</p>
          </div>
          <div class="footer">
            <p>This email was sent by Questie. If you have questions, please contact support.</p>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
      Reset Your Password - Questie
      
      Hi ${displayName || 'there'},
      
      We received a request to reset your Questie account password. Click the link below to create a new password:
      
      ${resetUrl}
      
      SECURITY NOTICE: This password reset link will expire in 1 hour for your security.
      
      If you didn't request a password reset, you can safely ignore this email. Your password will remain unchanged.
      
      Best regards,
      The Questie Team
    `
  })
};

// Email service functions
const emailService = {
  // Send email verification
  async sendVerificationEmail(email, displayName, verificationToken) {
    try {
      const verificationUrl = `${process.env.EMAIL_VERIFICATION_URL}/api/auth/verify-email?token=${verificationToken}`;
      const template = emailTemplates.verification(verificationUrl, displayName);
      
      const result = await resend.emails.send({
        from: `${process.env.EMAIL_NAME} <${process.env.EMAIL_FROM}>`,
        to: email,
        subject: 'Verify your email address - Questie',
        html: template.html,
        text: template.text
      });

      console.log('✅ Verification email sent:', { email, messageId: result.data?.id });
      return { success: true, messageId: result.data?.id };
    } catch (error) {
      console.error('❌ Failed to send verification email:', error);
      throw new Error('Failed to send verification email');
    }
  },

  // Send password reset email
  async sendPasswordResetEmail(email, displayName, resetToken) {
    try {
      const resetUrl = `${process.env.EMAIL_VERIFICATION_URL}/api/auth/reset-password?token=${resetToken}`;
      const template = emailTemplates.passwordReset(resetUrl, displayName);
      
      const result = await resend.emails.send({
        from: `${process.env.EMAIL_NAME} <${process.env.EMAIL_FROM}>`,
        to: email,
        subject: 'Reset your password - Questie',
        html: template.html,
        text: template.text
      });

      console.log('✅ Password reset email sent:', { email, messageId: result.data?.id });
      return { success: true, messageId: result.data?.id };
    } catch (error) {
      console.error('❌ Failed to send password reset email:', error);
      throw new Error('Failed to send password reset email');
    }
  }
};

module.exports = emailService;
