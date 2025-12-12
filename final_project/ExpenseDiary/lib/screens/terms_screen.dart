import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: const Color(0xFF4F9792),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          """
Last Updated: 2025

Please read these Terms & Conditions carefully before using the application.  
By accessing or using this app, you agree to be bound by the terms stated below.

1. Use of the Application
You agree to use the app solely for personal financial tracking and budgeting purposes.  
You must not misuse the app, attempt to hack, disrupt services, or engage in unauthorized access.

2. User Responsibilities
• Ensure all information entered (expenses, budgets, profile details) is accurate.  
• Maintain confidentiality of your login credentials.  
• You are responsible for all actions performed within your account.

3. Data & Content Ownership
You retain full ownership of the data you add to the app.  
The application does not claim rights over your personal financial entries or uploaded content.

4. Service Availability
While we aim to provide a smooth experience, we cannot guarantee uninterrupted service.  
Feature updates, maintenance, or technical issues may temporarily affect availability.

5. Third-Party Services
The app may integrate with:
• Authentication providers  
• Cloud database & storage  
• Currency conversion APIs  

We are not responsible for downtime, limitations, or policies of third-party services.

6. Limitation of Liability
The app provides financial tracking tools but does not offer financial advice.  
We are not liable for:
• Losses resulting from inaccurate entries  
• Budgeting decisions made by the user  
• Temporary or permanent data loss due to factors beyond our control  

Usage of the app is at your own risk.

7. Termination
We reserve the right to suspend or terminate accounts that violate these terms, misuse the app, or pose security risks.

8. Changes to Terms
We may update these Terms & Conditions periodically.  
Continued use of the app after updates implies acceptance of the revised terms.

9. Contact Us
For questions regarding these Terms & Conditions, please contact:  
thoufikumar1011@gmail.com
""",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
