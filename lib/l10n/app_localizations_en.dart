// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WaveMart';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonNoData => 'No data available';

  @override
  String get commonRetryMessage => 'Please try again';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get navHome => 'Home';

  @override
  String get navListings => 'Listings';

  @override
  String get navSearch => 'Search';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMessages => 'Messages';

  @override
  String get navSettings => 'Settings';

  @override
  String homeGreeting(Object name) {
    return 'Hi, $name';
  }

  @override
  String get homeDiscover => 'Discover your perfect property';

  @override
  String get homeFeaturedPremium => 'Premium properties';

  @override
  String get homeLatestRecently => 'Recently added';

  @override
  String get homeViewAll => 'View All';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileEditSubtitle => 'Update your information';

  @override
  String get profileMyListings => 'My Listings';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profileMessages => 'Messages';

  @override
  String get profilePayments => 'Payment History';

  @override
  String get profileKyc => 'KYC Verification';

  @override
  String get profileSubscriptions => 'Subscriptions';

  @override
  String get profileHelp => 'Help Center';

  @override
  String get profileNotLoggedIn => 'Not Logged In';

  @override
  String get profileLoginPrompt => 'Please log in to view your profile';

  @override
  String get profileVerificationPhone => 'Phone';

  @override
  String get profileVerificationKyc => 'KYC';

  @override
  String get profileStatsListings => 'Listings';

  @override
  String get profileStatsMessages => 'Messages';

  @override
  String get profileStatsFavorites => 'Favorites';

  @override
  String get profileKycStatusVerified => 'Verified';

  @override
  String get profileKycStatusPending => 'Pending';

  @override
  String get profileKycStatusRequired => 'Required';

  @override
  String get searchFilters => 'Filters';

  @override
  String get searchPropertyType => 'Property Type';

  @override
  String get searchListingStatus => 'Listing Status';

  @override
  String get searchPriceRange => 'Price Range';

  @override
  String get searchSortBy => 'Sort By';

  @override
  String get searchApplyFilters => 'Apply Filters';

  @override
  String get searchReset => 'Reset';

  @override
  String get searchPlaceholder => 'Search by location...';

  @override
  String get searchClearAll => 'Clear All';

  @override
  String get searchFindProperty => 'Find Your Perfect Property';

  @override
  String get searchWelcomeSubtitle =>
      'Search by location, filter by type and status to discover amazing properties';

  @override
  String get searchPopular => 'Popular Searches';

  @override
  String get searchUnder5M => '💰 Under 5M';

  @override
  String get search5M10M => '💎 5M - 10M';

  @override
  String get search10M50M => '🏆 10M - 50M';

  @override
  String get search50M100M => '👑 50M - 100M';

  @override
  String get search100MPlus => '✨ 100M+';

  @override
  String get searchNoResultsTitle => 'No Properties Found';

  @override
  String get searchNoResultsSubtitle =>
      'Try adjusting your search or filters to find more results';

  @override
  String searchFoundCount(Object count) {
    return '$count properties found';
  }

  @override
  String get searchSortNewest => '🆕 Newest';

  @override
  String get searchSortOldest => '📅 Oldest';

  @override
  String get searchSortPriceLow => '💰 Price ↑';

  @override
  String get searchSortPriceHigh => '💎 Price ↓';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterAny => 'Any';

  @override
  String get listingNew => 'NEW';

  @override
  String get listingFeatured => 'FEATURED';

  @override
  String get listingHouse => '🏠 House';

  @override
  String get listingLand => '🌄 Land';

  @override
  String get listingHouses => '🏠 Houses';

  @override
  String get listingLands => '🌄 Lands';

  @override
  String get listingPriceOnRequest => 'Price on Request';

  @override
  String get listingUnknownLocation => 'Unknown Location';

  @override
  String get listingToday => 'Today';

  @override
  String get listingYesterday => 'Yesterday';

  @override
  String listingDaysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String listingWeeksAgo(Object count) {
    return '$count weeks ago';
  }

  @override
  String listingMonthsAgo(Object count) {
    return '$count months ago';
  }

  @override
  String get listingSale => '💰 Sale';

  @override
  String get listingRent => '🔑 Rent';

  @override
  String get listingForSale => '💰 For Sale';

  @override
  String get listingForRent => '🔑 For Rent';

  @override
  String listingUnitM2(Object count) {
    return '$count m²';
  }

  @override
  String get listingsTitle => 'Listings';

  @override
  String get listingsCreate => 'Create Listing';

  @override
  String get listingsFeatured => 'Featured';

  @override
  String get listingsNoResults => 'No listings found';

  @override
  String get listingsDetails => 'Property Details';

  @override
  String get listingsKeyFeatures => 'Key Features';

  @override
  String get listingsDescription => 'Description';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle =>
      'Start adding properties to your favorites';

  @override
  String get favoritesRemove => 'Remove from favorites';

  @override
  String get favoritesAdded => 'Added to favorites';

  @override
  String get favoritesRemoved => 'Removed from favorites';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'No messages yet';

  @override
  String get messagesTypeMessage => 'Type a message...';

  @override
  String get messagesSend => 'Send';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'My Account';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get settingsSectionAuth => 'Account';

  @override
  String get settingsMyListingsSubtitle => 'Manage your properties';

  @override
  String get settingsSubscriptionsSubtitle => 'View your plans';

  @override
  String get settingsPaymentsSubtitle => 'Transaction history';

  @override
  String get settingsKycVerified => 'Verified';

  @override
  String get settingsKycRequired => 'Required';

  @override
  String get settingsHelpSubtitle => 'FAQs and guides';

  @override
  String get settingsContactSupport => 'Contact Support';

  @override
  String get settingsContactSupportSubtitle => 'Get in touch';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String settingsWebOpenError(Object title) {
    return 'Could not open $title';
  }

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Change app language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Select app theme';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Manage notifications';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySubtitle => 'Privacy settings';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'About WaveMart';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutSubtitle => 'Sign out of your account';

  @override
  String get languageTitle => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'አማርኛ (Amharic)';

  @override
  String get languageTigrinya => 'ትግርኛ (Tigrinya)';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authEnterPhone => 'Enter your phone number';

  @override
  String get authSendOtp => 'Send OTP';

  @override
  String get authVerifyOtp => 'Verify OTP';

  @override
  String get authEnterOtp => 'Enter 6-digit OTP';

  @override
  String get authResendOtp => 'Resend OTP';

  @override
  String get authLogin => 'Login';

  @override
  String get authRegister => 'Register';

  @override
  String get authLogout => 'Logout';

  @override
  String get authLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String get subscriptionsTitle => 'Subscription Plans';

  @override
  String get subscriptionsSubtitle => 'Select a plan that fits your needs';

  @override
  String get subscriptionsCurrentPlan => 'Current Plan';

  @override
  String get subscriptionsFree => 'Free';

  @override
  String get subscriptionsBasic => 'Basic';

  @override
  String get subscriptionsPremium => 'Premium';

  @override
  String get subscriptionsSubscribe => 'Subscribe Now';

  @override
  String get subscriptionsSelectPlan => 'Select Plan';
}
