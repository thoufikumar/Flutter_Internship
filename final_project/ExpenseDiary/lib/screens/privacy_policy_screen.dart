import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: const Color(0xFF4F9792),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          """
Last Updated: 2025

This Privacy Policy explains how we collect, use, and protect your information when you use our application.

1. Information We Collect
• Account Information: Name, email, profile photo (optional).  
• Usage Data: Expense entries, budget records, analytics.  
• Device Information: Basic device details for performance optimization.

We do not collect any financial credentials such as bank account numbers, card details, UPI IDs, or passwords.

2. How We Use Your Information
Your data is used to:
• Provide and improve app features (expense tracking, budget management, insights).  
• Sync your information securely across devices using cloud services.  
• Personalize your experience (currency preferences, profile settings).  
• Improve app stability, performance, and security.

We do NOT sell, trade, or rent your personal information to third parties.

3. Data Storage & Security
Your data is stored using secure cloud infrastructure (e.g., Firebase).  
We implement:
• Authentication-based access  
• Encrypted communication (HTTPS)  
• Strict internal access controls  

While we follow industry-standard security measures, no system can guarantee 100% protection.

4. Third-Party Services
The app may use trusted third-party providers for:
• Authentication  
• Cloud database & file storage  
• Currency conversion API  

These services have their own privacy policies, which users are encouraged to review.

5. Your Choices
• You may update or delete your profile anytime.  
• You may delete your account by contacting support — this removes your data permanently.  
• You may manage app permissions (camera, storage, etc.) from device settings.

6. Changes to This Policy
We may update this Privacy Policy periodically.  
Any changes will be reflected with an updated “Last Updated” date.

7. Contact Us
If you have questions or concerns, please contact:  
thoufikumar1011@gmail.com
""",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
