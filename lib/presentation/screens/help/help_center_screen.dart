import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Help Center Screen - Browse FAQs and guides
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<_HelpArticle> _filteredArticles = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredArticles = _allArticles;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles
            .where((article) =>
                article.title.toLowerCase().contains(query) ||
                article.content.toLowerCase().contains(query) ||
                article.category.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.zinc50,
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildCategorySection(
          icon: Icons.account_circle_outlined,
          title: 'Account & Profile',
          articles: _allArticles
              .where((a) => a.category == 'Account')
              .toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.home_outlined,
          title: 'Listings',
          articles: _allArticles
              .where((a) => a.category == 'Listings')
              .toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.payment_outlined,
          title: 'Payments & Subscriptions',
          articles: _allArticles
              .where((a) => a.category == 'Payments')
              .toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.verified_user_outlined,
          title: 'KYC Verification',
          articles: _allArticles
              .where((a) => a.category == 'KYC')
              .toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.security_outlined,
          title: 'Safety & Policies',
          articles: _allArticles
              .where((a) => a.category == 'Safety')
              .toList(),
        ),
        const SizedBox(height: 32),

        // Contact support
        _buildContactSupport(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCategorySection({
    required IconData icon,
    required String title,
    required List<_HelpArticle> articles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.wave600),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleSmall),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.zinc200),
          ),
          child: Column(
            children: articles.asMap().entries.map((entry) {
              final index = entry.key;
              final article = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.article_outlined,
                      size: 20,
                      color: AppColors.navy500,
                    ),
                    title: Text(
                      article.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.zinc400,
                    ),
                    onTap: () => _showArticleDetail(article),
                  ),
                  if (index < articles.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_filteredArticles.isEmpty) {
      return const WaveEmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'Try different keywords or browse categories',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredArticles.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final article = _filteredArticles[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.wave50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.article_outlined,
              size: 20,
              color: AppColors.wave600,
            ),
          ),
          title: Text(
            article.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            article.category,
            style: AppTextStyles.caption,
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.zinc400),
          onTap: () => _showArticleDetail(article),
        );
      },
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientWave,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Still need help?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Our support team is here to help you.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchEmail(),
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Email'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchPhone(),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showArticleDetail(_HelpArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.zinc300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        style: AppTextStyles.title,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      article.content,
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.8,
                        color: AppColors.navy700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:support@wavemart.et');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+251911000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone app')),
        );
      }
    }
  }
}

class _HelpArticle {
  final String title;
  final String content;
  final String category;

  _HelpArticle({required this.title, required this.content, required this.category});
}

final List<_HelpArticle> _allArticles = [
  // Account
  _HelpArticle(
    title: 'How to create an account',
    content: 'To create an account on WaveMart:\n\n1. Open the app and tap on "Sign Up"\n2. Enter your phone number or email address\n3. You will receive an OTP (One-Time Password)\n4. Enter the OTP to verify your account\n5. Complete your profile by adding your name and other details\n\nOnce registered, you can browse listings, create your own listings, and communicate with other users.',
    category: 'Account',
  ),
  _HelpArticle(
    title: 'How to edit your profile',
    content: 'To edit your profile information:\n\n1. Go to the Profile tab\n2. Tap on "Edit Profile"\n3. Update your name, email, or other details\n4. Tap "Save" to confirm changes\n\nYour profile information helps other users identify you when communicating about listings.',
    category: 'Account',
  ),
  _HelpArticle(
    title: 'How to reset your password',
    content: 'If you need to reset your password:\n\n1. On the login screen, tap "Forgot Password"\n2. Enter your registered phone number or email\n3. You will receive an OTP\n4. Enter the OTP and set a new password\n\nMake sure to use a strong password that you do not share with others.',
    category: 'Account',
  ),

  // Listings
  _HelpArticle(
    title: 'How to create a listing',
    content: 'To create a property listing:\n\n1. Tap the "+" button in the bottom navigation\n2. Select your property type (House or Land)\n3. Choose listing type (For Sale or For Rent)\n4. Fill in property details: price, area, description\n5. Add location information\n6. Upload clear photos of your property (up to 10 images)\n7. Review your listing and submit\n\nYour listing will be reviewed before it goes live. This usually takes a few hours.',
    category: 'Listings',
  ),
  _HelpArticle(
    title: 'How to manage your listings',
    content: 'To manage your property listings:\n\n1. Go to Settings > My Listings\n2. Here you can see all your active listings\n3. Tap on a listing to view its details\n4. You can edit or delete listings from the listing detail page\n\nInactive or pending listings will also appear here with their current status.',
    category: 'Listings',
  ),
  _HelpArticle(
    title: 'Tips for a great listing',
    content: 'Make your listing stand out:\n\n1. Use clear, well-lit photos (at least 5 images)\n2. Write a detailed description of the property\n3. Include accurate location details\n4. Set a competitive and realistic price\n5. Mention nearby amenities and landmarks\n6. Specify any unique features of the property\n7. Respond promptly to inquiries from interested buyers',
    category: 'Listings',
  ),

  // Payments
  _HelpArticle(
    title: 'Subscription plans explained',
    content: 'WaveMart offers several subscription plans:\n\n- Free Plan: Basic access with limited listings\n- Basic Plan: More listings and basic features\n- Premium Plan: Maximum listings and all features including featured listings\n\nEach plan has different benefits and pricing. You can upgrade or change your plan at any time from the Subscriptions page.',
    category: 'Payments',
  ),
  _HelpArticle(
    title: 'How to make a payment',
    content: 'To subscribe to a plan:\n\n1. Go to Settings > Subscriptions\n2. Choose your desired plan\n3. Tap "Subscribe Now"\n4. You will be redirected to Chapa payment gateway\n5. Complete the payment using your preferred method\n6. Once payment is confirmed, your subscription activates immediately\n\nYou can view all your payment transactions in Settings > Payment History.',
    category: 'Payments',
  ),
  _HelpArticle(
    title: 'Payment security',
    content: 'All payments on WaveMart are processed securely through Chapa, a trusted Ethiopian payment gateway.\n\nWe do not store your payment card information. All transactions are encrypted and processed securely.\n\nIf you notice any issues with payments, contact our support team immediately.',
    category: 'Payments',
  ),

  // KYC
  _HelpArticle(
    title: 'What is KYC and why is it required?',
    content: 'KYC (Know Your Customer) is a verification process that confirms your identity.\n\nKYC is required to:\n- Create property listings\n- Build trust with other users\n- Comply with local regulations\n- Prevent fraud and misuse\n\nThe verification process is quick and your documents are handled securely.',
    category: 'KYC',
  ),
  _HelpArticle(
    title: 'How to complete KYC verification',
    content: 'To complete KYC verification:\n\n1. Go to Settings > KYC Verification\n2. Select your document type (National ID or Passport)\n3. Upload a clear photo of the front of your document\n4. For National ID, also upload the back side\n5. Take a selfie holding your document next to your face\n6. Submit for review\n\nVerification usually takes 24-48 hours. You will be notified once your identity is verified.',
    category: 'KYC',
  ),
  _HelpArticle(
    title: 'Why was my KYC rejected?',
    content: 'Common reasons for KYC rejection:\n\n1. Blurry or unreadable document photos\n2. Document is expired or invalid\n3. Selfie does not clearly show your face and document\n4. Document type does not match selection\n5. Cropped or incomplete document images\n\nTo resubmit:\n- Go to KYC Verification\n- Tap "Resubmit Documents"\n- Ensure all photos are clear and well-lit\n- Make sure the entire document is visible',
    category: 'KYC',
  ),

  // Safety
  _HelpArticle(
    title: 'Staying safe on WaveMart',
    content: 'Tips for safe transactions:\n\n1. Always meet in public places for property viewings\n2. Never share personal financial information\n3. Verify property ownership before making payments\n4. Use the in-app messaging system for communication\n5. Report suspicious activity to our support team\n6. Do not send money without seeing the property\n7. Consider using a legal professional for property transactions',
    category: 'Safety',
  ),
  _HelpArticle(
    title: 'Privacy Policy',
    content: 'WaveMart respects your privacy and protects your personal data.\n\nWe collect:\n- Account information (name, phone, email)\n- Listing data you provide\n- Usage analytics to improve the app\n\nWe do not:\n- Sell your personal data\n- Share your information with third parties (except for necessary services like payment processing)\n- Store your payment details\n\nFor full details, visit our website or contact support.',
    category: 'Safety',
  ),
  _HelpArticle(
    title: 'Reporting a problem',
    content: 'If you encounter any issues:\n\n1. Use the in-app Help Center to find solutions\n2. Contact support via email: support@wavemart.et\n3. Call our support line for urgent issues\n4. Report suspicious listings or users through the listing detail page\n\nWe aim to respond to all inquiries within 24 hours.',
    category: 'Safety',
  ),
];
