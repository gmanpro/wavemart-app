import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ti.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('ti')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WaveMart'**
  String get appTitle;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get commonNoData;

  /// No description provided for @commonRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get commonRetryMessage;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get navListings;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(Object name);

  /// No description provided for @homeDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover your perfect property'**
  String get homeDiscover;

  /// No description provided for @homeFeaturedPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium properties'**
  String get homeFeaturedPremium;

  /// No description provided for @homeLatestRecently.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeLatestRecently;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get profileEditSubtitle;

  /// No description provided for @profileMyListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get profileMyListings;

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavorites;

  /// No description provided for @profileMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileMessages;

  /// No description provided for @profilePayments.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get profilePayments;

  /// No description provided for @profileKyc.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get profileKyc;

  /// No description provided for @profileSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get profileSubscriptions;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get profileHelp;

  /// No description provided for @profileNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get profileNotLoggedIn;

  /// No description provided for @profileLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile'**
  String get profileLoginPrompt;

  /// No description provided for @profileVerificationPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profileVerificationPhone;

  /// No description provided for @profileVerificationKyc.
  ///
  /// In en, this message translates to:
  /// **'KYC'**
  String get profileVerificationKyc;

  /// No description provided for @profileStatsListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get profileStatsListings;

  /// No description provided for @profileStatsMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileStatsMessages;

  /// No description provided for @profileStatsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileStatsFavorites;

  /// No description provided for @profileKycStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileKycStatusVerified;

  /// No description provided for @profileKycStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get profileKycStatusPending;

  /// No description provided for @profileKycStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get profileKycStatusRequired;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilters;

  /// No description provided for @searchPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get searchPropertyType;

  /// No description provided for @searchListingStatus.
  ///
  /// In en, this message translates to:
  /// **'Listing Status'**
  String get searchListingStatus;

  /// No description provided for @searchPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get searchPriceRange;

  /// No description provided for @searchSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get searchSortBy;

  /// No description provided for @searchApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get searchApplyFilters;

  /// No description provided for @searchReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get searchReset;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by location...'**
  String get searchPlaceholder;

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get searchClearAll;

  /// No description provided for @searchFindProperty.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Property'**
  String get searchFindProperty;

  /// No description provided for @searchWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search by location, filter by type and status to discover amazing properties'**
  String get searchWelcomeSubtitle;

  /// No description provided for @searchPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get searchPopular;

  /// No description provided for @searchUnder5M.
  ///
  /// In en, this message translates to:
  /// **'💰 Under 5M'**
  String get searchUnder5M;

  /// No description provided for @search5M10M.
  ///
  /// In en, this message translates to:
  /// **'💎 5M - 10M'**
  String get search5M10M;

  /// No description provided for @search10M50M.
  ///
  /// In en, this message translates to:
  /// **'🏆 10M - 50M'**
  String get search10M50M;

  /// No description provided for @search50M100M.
  ///
  /// In en, this message translates to:
  /// **'👑 50M - 100M'**
  String get search50M100M;

  /// No description provided for @search100MPlus.
  ///
  /// In en, this message translates to:
  /// **'✨ 100M+'**
  String get search100MPlus;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Properties Found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters to find more results'**
  String get searchNoResultsSubtitle;

  /// No description provided for @searchFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count} properties found'**
  String searchFoundCount(Object count);

  /// No description provided for @searchSortNewest.
  ///
  /// In en, this message translates to:
  /// **'🆕 Newest'**
  String get searchSortNewest;

  /// No description provided for @searchSortOldest.
  ///
  /// In en, this message translates to:
  /// **'📅 Oldest'**
  String get searchSortOldest;

  /// No description provided for @searchSortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'💰 Price ↑'**
  String get searchSortPriceLow;

  /// No description provided for @searchSortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'💎 Price ↓'**
  String get searchSortPriceHigh;

  /// No description provided for @searchFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchFilterAll;

  /// No description provided for @searchFilterAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get searchFilterAny;

  /// No description provided for @listingNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get listingNew;

  /// No description provided for @listingFeatured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get listingFeatured;

  /// No description provided for @listingHouse.
  ///
  /// In en, this message translates to:
  /// **'🏠 House'**
  String get listingHouse;

  /// No description provided for @listingLand.
  ///
  /// In en, this message translates to:
  /// **'🌄 Land'**
  String get listingLand;

  /// No description provided for @listingHouses.
  ///
  /// In en, this message translates to:
  /// **'🏠 Houses'**
  String get listingHouses;

  /// No description provided for @listingLands.
  ///
  /// In en, this message translates to:
  /// **'🌄 Lands'**
  String get listingLands;

  /// No description provided for @listingPriceOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Price on Request'**
  String get listingPriceOnRequest;

  /// No description provided for @listingUnknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get listingUnknownLocation;

  /// No description provided for @listingToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get listingToday;

  /// No description provided for @listingYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get listingYesterday;

  /// No description provided for @listingDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String listingDaysAgo(Object count);

  /// No description provided for @listingWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String listingWeeksAgo(Object count);

  /// No description provided for @listingMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String listingMonthsAgo(Object count);

  /// No description provided for @listingSale.
  ///
  /// In en, this message translates to:
  /// **'💰 Sale'**
  String get listingSale;

  /// No description provided for @listingRent.
  ///
  /// In en, this message translates to:
  /// **'🔑 Rent'**
  String get listingRent;

  /// No description provided for @listingForSale.
  ///
  /// In en, this message translates to:
  /// **'💰 For Sale'**
  String get listingForSale;

  /// No description provided for @listingForRent.
  ///
  /// In en, this message translates to:
  /// **'🔑 For Rent'**
  String get listingForRent;

  /// No description provided for @listingUnitM2.
  ///
  /// In en, this message translates to:
  /// **'{count} m²'**
  String listingUnitM2(Object count);

  /// No description provided for @listingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listingsTitle;

  /// No description provided for @listingsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get listingsCreate;

  /// No description provided for @listingsFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get listingsFeatured;

  /// No description provided for @listingsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get listingsNoResults;

  /// No description provided for @listingsDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get listingsDetails;

  /// No description provided for @listingsKeyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get listingsKeyFeatures;

  /// No description provided for @listingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get listingsDescription;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding properties to your favorites'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoritesRemove;

  /// No description provided for @favoritesAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoritesAdded;

  /// No description provided for @favoritesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoritesRemoved;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmpty;

  /// No description provided for @messagesTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messagesTypeMessage;

  /// No description provided for @messagesSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get messagesSend;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSectionSupport;

  /// No description provided for @settingsSectionAuth.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAuth;

  /// No description provided for @settingsMyListingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your properties'**
  String get settingsMyListingsSubtitle;

  /// No description provided for @settingsSubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your plans'**
  String get settingsSubscriptionsSubtitle;

  /// No description provided for @settingsPaymentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get settingsPaymentsSubtitle;

  /// No description provided for @settingsKycVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get settingsKycVerified;

  /// No description provided for @settingsKycRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get settingsKycRequired;

  /// No description provided for @settingsHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs and guides'**
  String get settingsHelpSubtitle;

  /// No description provided for @settingsContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settingsContactSupport;

  /// No description provided for @settingsContactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch'**
  String get settingsContactSupportSubtitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsWebOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open {title}'**
  String settingsWebOpenError(Object title);

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app theme'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About WaveMart'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get settingsLogoutSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageAmharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ (Amharic)'**
  String get languageAmharic;

  /// No description provided for @languageTigrinya.
  ///
  /// In en, this message translates to:
  /// **'ትግርኛ (Tigrinya)'**
  String get languageTigrinya;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authEnterPhone;

  /// No description provided for @authSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get authSendOtp;

  /// No description provided for @authVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get authVerifyOtp;

  /// No description provided for @authEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get authEnterOtp;

  /// No description provided for @authResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get authResendOtp;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get authLogoutConfirm;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionsTitle;

  /// No description provided for @subscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a plan that fits your needs'**
  String get subscriptionsSubtitle;

  /// No description provided for @subscriptionsCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get subscriptionsCurrentPlan;

  /// No description provided for @subscriptionsFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionsFree;

  /// No description provided for @subscriptionsBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get subscriptionsBasic;

  /// No description provided for @subscriptionsPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get subscriptionsPremium;

  /// No description provided for @subscriptionsSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscriptionsSubscribe;

  /// No description provided for @subscriptionsSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get subscriptionsSelectPlan;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'ti'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'ti':
      return AppLocalizationsTi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
