// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tigrinya (`ti`).
class AppLocalizationsTi extends AppLocalizations {
  AppLocalizationsTi([String locale = 'ti']) : super(locale);

  @override
  String get appTitle => 'ዌቭማርት';

  @override
  String get commonUser => 'ተጠቃሚ';

  @override
  String get commonNA => 'የለን';

  @override
  String get commonAppInitials => 'ዌማ';

  @override
  String get commonUnknown => 'ዘይፍለጥ';

  @override
  String get commonOk => 'እሺ';

  @override
  String get commonCancel => 'ይሰረዝ';

  @override
  String get commonSave => 'ዓቅብ';

  @override
  String get commonDelete => 'ሰርዝ';

  @override
  String get commonEdit => 'ኣዐሪ';

  @override
  String get commonRetry => 'ደጊምካ ፈትን';

  @override
  String get commonLoading => 'ይፅዕን ኣሎ...';

  @override
  String get commonError => 'ጌጋ';

  @override
  String get commonSuccess => 'ተሳኪዑ';

  @override
  String get commonNoData => 'ዝተረኽበ መረዳእታ የለን';

  @override
  String get commonRetryMessage => 'በጃኹም ደጊምኩም ፈትኑ';

  @override
  String get commonComingSoon => 'ብቀረባ እዋን ክመጽእ እዩ';

  @override
  String get navHome => 'መበገሲ';

  @override
  String get navListings => 'ንብረታት';

  @override
  String get navSearch => 'ደለይ';

  @override
  String get navFavorites => 'ዝተመርፁ';

  @override
  String get navProfile => 'መገለጺ';

  @override
  String get navMessages => 'መልእኽታት';

  @override
  String get navSettings => 'ቅጥዒታት';

  @override
  String homeGreeting(Object name) {
    return 'ሰላም፣ $name';
  }

  @override
  String get homeDiscover => 'ዝበለጸ ንብረትኩም ኣብዚ ረኸቡ';

  @override
  String get homeFeaturedPremium => 'ፍሉያት ንብረታት';

  @override
  String get homeLatestRecently => 'ብቀረባ ዝወጹ';

  @override
  String get homeViewAll => 'ኹሉ ተዓዘብ';

  @override
  String get profileTitle => 'መገለጺ';

  @override
  String get profileEdit => 'መገለጺ ኣዐሪ';

  @override
  String get profileEditSubtitle => 'ሓበሬታኹም ኣሐድሱ';

  @override
  String get profileMyListings => 'ናተይ ንብረታት';

  @override
  String get profileFavorites => 'ዝተመርፁ';

  @override
  String get profileMessages => 'መልእኽታት';

  @override
  String get profilePayments => 'ታሪኽ ክፍሊት';

  @override
  String get profileKyc => 'መረጋገጺ መንነት (KYC)';

  @override
  String get profileSubscriptions => 'ናይ ኣባልነት ትልምታት';

  @override
  String get profileHelp => 'መእከሊ ሓገዝ';

  @override
  String get profileNotLoggedIn => 'ኣይኣተኹምን';

  @override
  String get profileLoginPrompt => 'በጃኹም መገለጺኹም ንምርኣይ እተዉ';

  @override
  String get profileVerificationPhone => 'ተሌፎን';

  @override
  String get profileVerificationKyc => 'KYC';

  @override
  String get profileStatsListings => 'ንብረታት';

  @override
  String get profileStatsMessages => 'መልእኽታት';

  @override
  String get profileStatsFavorites => 'ዝተመርፁ';

  @override
  String get profileKycStatusVerified => 'ተረጋጊጹ';

  @override
  String get profileKycStatusPending => 'ኣብ መስርሕ';

  @override
  String get profileKycStatusRequired => 'የድሊ';

  @override
  String get searchFilters => 'መጻረዪታት';

  @override
  String get searchPropertyType => 'ዓይነት ንብረት';

  @override
  String get searchListingStatus => 'ኵነታት መሸጣ/ክራይ';

  @override
  String get searchPriceRange => 'ናይ ዋጋ ክልል';

  @override
  String get searchSortBy => 'ደረጃ ኣሰያይማ';

  @override
  String get searchApplyFilters => 'መጻረዪታት ተጠቐም';

  @override
  String get searchReset => 'ኣሐድስ';

  @override
  String get searchPlaceholder => 'ብቦታ ደለይ...';

  @override
  String get searchClearAll => 'ኹሉ ኣጥፍእ';

  @override
  String get searchFindProperty => 'ዝበለጸ ንብረትኩም ረኸቡ';

  @override
  String get searchWelcomeSubtitle => 'ንብረታት ብቦታ፣ ብዓይነትን ብኵነታትን ደለዩ';

  @override
  String get searchPopular => 'ተፈተውቲ ዳህሳሳት';

  @override
  String get searchUnder5M => '💰 ትሕቲ 5 ሚልዮን';

  @override
  String get search5M10M => '💎 5-10 ሚልዮን';

  @override
  String get search10M50M => '🏆 10-50 ሚልዮን';

  @override
  String get search50M100M => '👑 50-100 ሚልዮን';

  @override
  String get search100MPlus => '✨ ልዕሊ 100 ሚልዮን';

  @override
  String get searchNoResultsTitle => 'ዝተረኽበ ንብረት የለን';

  @override
  String get searchNoResultsSubtitle => 'በጃኹም ዳህሳስኩም ወይ መጻረዪኹም ቀይርኩም ፈትኑ';

  @override
  String searchFoundCount(Object count) {
    return '$count ንብረታት ተረኺቦም';
  }

  @override
  String get searchSortNewest => '🆕 ሓድሽ';

  @override
  String get searchSortOldest => '📅 ዝጸንሐ';

  @override
  String get searchSortPriceLow => '💰 ትሑት ዋጋ';

  @override
  String get searchSortPriceHigh => '💎 ልዑል ዋጋ';

  @override
  String get searchFilterAll => 'ኹሉ';

  @override
  String get searchFilterAny => 'ዝኾነ';

  @override
  String get listingNew => 'ሓድሽ';

  @override
  String get listingFeatured => 'ፍሉይ';

  @override
  String get listingHouse => '🏠 ገዛ';

  @override
  String get listingLand => '🌄 መሬት';

  @override
  String get listingHouses => '🏠 ገዛውቲ';

  @override
  String get listingLands => '🌄 መሬታት';

  @override
  String get listingPriceOnRequest => 'ዋጋ ብሕቶ';

  @override
  String get listingUnknownLocation => 'ዘይፍለጥ ቦታ';

  @override
  String get listingToday => 'ሎሚ';

  @override
  String get listingYesterday => 'ትማሊ';

  @override
  String listingDaysAgo(Object count) {
    return 'ቅድሚ $count መዓልቲ';
  }

  @override
  String listingWeeksAgo(Object count) {
    return 'ቅድሚ $count ሰሙን';
  }

  @override
  String listingMonthsAgo(Object count) {
    return 'ቅድሚ $count ወርሒ';
  }

  @override
  String get listingSale => '💰 መሸጣ';

  @override
  String get listingRent => '🔑 ክራይ';

  @override
  String get listingForSale => '💰 ንመሸጣ';

  @override
  String get listingForRent => '🔑 ንክራይ';

  @override
  String listingUnitM2(Object count) {
    return '$count ሜትር ካሬ';
  }

  @override
  String get listingsTitle => 'ንብረታት';

  @override
  String get listingsCreate => 'ንብረት ኣእቱ';

  @override
  String get listingsFeatured => 'ፍሉያት ንብረታት';

  @override
  String get listingsNoResults => 'ዝተረኽበ ንብረት የለን';

  @override
  String get listingsDetails => 'ዝርዝር ንብረት';

  @override
  String get listingsKeyFeatures => 'ቀንዲ መገለጺታት';

  @override
  String get listingsDescription => 'መግለጺ';

  @override
  String get listingsPropertyDetails => 'ዝርዝር ንብረት';

  @override
  String listingsBedrooms(Object count) {
    return '$count መኝታ ክፍል';
  }

  @override
  String listingsBathrooms(Object count) {
    return '$count ሽቓቕ';
  }

  @override
  String listingsSalons(Object count) {
    return '$count ሳሎን';
  }

  @override
  String get listingsFrontArea => 'ናይ ቅድሚት ስፍሓት';

  @override
  String get listingsSideArea => 'ናይ ጎኒ ስፍሓት';

  @override
  String get listingsUseType => 'ዓይነት ኣገልግሎት';

  @override
  String get listingsHoldingType => 'ዓይነት ዋናነት';

  @override
  String get listingsFacing => 'ኣንፈት';

  @override
  String get listingsNegotiable => 'ብድርድር';

  @override
  String get listingsEncumbrance => 'ዕዳ/እገዳ';

  @override
  String listingsEncumbranceYes(Object amount) {
    return 'እወ ($amount ቅርሺ)';
  }

  @override
  String get listingsVideoTour => 'ናይ ቪዲዮ ዑደት';

  @override
  String get listingsNoDescription => 'መግለጺ ኣይተዋህበን';

  @override
  String get listingsNoFeatures => 'ቀንዲ መገለጺታት ኣይተጠቐሱን';

  @override
  String get listingsNotFound => 'ንብረቱ ኣይተረኽበን';

  @override
  String get listingsNotFoundSubtitle => 'እዚ ንብረት ተሰሪዙ ክኸውን ይኽእል እዩ';

  @override
  String get listingsLoadError => 'ንብረቱ ክጽዕን ኣይከኣለን';

  @override
  String listingsTitleTemplate(Object type, Object action, Object location) {
    return '$type $action ኣብ $location';
  }

  @override
  String listingsPriceFixed(Object price) {
    return '$price ቅርሺ';
  }

  @override
  String listingsPriceRange(Object min, Object max) {
    return '$min - $max ቅርሺ';
  }

  @override
  String get listingsYes => 'እወ';

  @override
  String get listingsNo => 'የለን';

  @override
  String get favoritesTitle => 'ዝተመርፁ';

  @override
  String get favoritesEmpty => 'ዝተመርጸ ንብረት የለን';

  @override
  String get favoritesEmptySubtitle => 'ዝመረጽኩምዎም ንብረታት ኣብዚ ክትረኽብዎም ኢኹም';

  @override
  String get favoritesRemove => 'ካብ ዝተመርፁ ኣውጽእ';

  @override
  String get favoritesAdded => 'ናብ ዝተመርፁ ተወሲኹ';

  @override
  String get favoritesRemoved => 'ካብ ዝተመርፁ ወጺኡ';

  @override
  String get messagesTitle => 'መልእኽታት';

  @override
  String get messagesEmpty => 'መልእኽቲ የለን';

  @override
  String get messagesTypeMessage => 'መልእኽቲ ጽሓፉ...';

  @override
  String get messagesSend => 'ስደድ';

  @override
  String get settingsTitle => 'ቅጥዒታት';

  @override
  String get settingsSectionAccount => 'ናይ መለያ ሓበሬታ';

  @override
  String get settingsSectionSupport => 'ሓገዝ';

  @override
  String get settingsSectionAuth => 'መለያ';

  @override
  String get settingsMyListingsSubtitle => 'ንብረትኩም ኣመሓድሩ';

  @override
  String get settingsSubscriptionsSubtitle => 'ትልምታትኩም ርኣዩ';

  @override
  String get settingsPaymentsSubtitle => 'ታሪኽ ክፍሊት';

  @override
  String get settingsKycVerified => 'ተረጋጊጹ';

  @override
  String get settingsKycRequired => 'የድሊ';

  @override
  String get settingsHelpSubtitle => 'ሕቶታትን መምርሒታትን';

  @override
  String get settingsContactSupport => 'ሓገዝ ረኸቡ';

  @override
  String get settingsContactSupportSubtitle => 'ተወከሱና';

  @override
  String get settingsPrivacyPolicy => 'ፖሊሲ ምስጢራውነት';

  @override
  String get settingsTermsOfService => 'ውዕል ኣገልግሎት';

  @override
  String settingsWebOpenError(Object title) {
    return '$title ክኽፈት ኣይከኣለን';
  }

  @override
  String get settingsPreferences => 'ምርጫታት';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsLanguageSubtitle => 'ናይ መተግበሪ ቋንቋ ቀይሩ';

  @override
  String get settingsTheme => 'መልክዕ';

  @override
  String get settingsThemeSubtitle => 'ናይ መተግበሪ መልክዕ ይምረጡ';

  @override
  String get settingsNotifications => 'መጠንቀቕታታት';

  @override
  String get settingsNotificationsSubtitle => 'መጠንቀቕታታት ኣመሓድሩ';

  @override
  String get settingsPrivacy => 'ምስጢራውነት';

  @override
  String get settingsPrivacySubtitle => 'ቅጥዒታት ምስጢራውነት';

  @override
  String get settingsAbout => 'ብዛዕባ ዌቭማርት';

  @override
  String get settingsAboutSubtitle => 'ሓበሬታ ብዛዕባ መተግበሪ';

  @override
  String get settingsLogout => 'ውጻእ';

  @override
  String get settingsLogoutSubtitle => 'ካብ መለያኹም ንምውጻእ';

  @override
  String get languageTitle => 'ቋንቋ ይምረጡ';

  @override
  String get languageEnglish => 'English (እንግሊዝኛ)';

  @override
  String get languageAmharic => 'አማርኛ (ኣምሓርኛ)';

  @override
  String get languageTigrinya => 'ትግርኛ';

  @override
  String get languageChanged => 'ቋንቋ ብዝግባእ ተቐይሩ';

  @override
  String get authPhoneNumber => 'ቁጽሪ ተሌፎን';

  @override
  String get authEnterPhone => 'ቁጽሪ ተሌፎንኩም ኣእትዉ';

  @override
  String get authSendOtp => 'ኮድ ስደድ';

  @override
  String get authVerifyOtp => 'ኮድ ኣረጋግጽ';

  @override
  String get authEnterOtp => 'ባለ 6 ኣሃዝ ኮድ ኣእትዉ';

  @override
  String get authResendOtp => 'ኮድ ደጊምካ ስደድ';

  @override
  String get authLogin => 'እቶ';

  @override
  String get authRegister => 'ተመዝገብ';

  @override
  String get authLogout => 'ውጻእ';

  @override
  String get authLogoutConfirm => 'ርግጸኛ ዲኹም ክትወጽኡ ትደልዩ?';

  @override
  String get subscriptionsTitle => 'ናይ ኣባልነት ትልምታት';

  @override
  String get subscriptionsSubtitle => 'ንዓኹም ዝበቅዕ ትልሚ ይምረጡ';

  @override
  String get subscriptionsCurrentPlan => 'ናይ ሕጂ ትልሚ';

  @override
  String get subscriptionsFree => 'ብናጻ';

  @override
  String get subscriptionsBasic => 'መሰረታዊ';

  @override
  String get subscriptionsPremium => 'ፕሪሚየም';

  @override
  String get subscriptionsSubscribe => 'ሕጂ ተመዝገብ';

  @override
  String get subscriptionsSelectPlan => 'ትልሚ ይምረጡ';

  @override
  String get profileMyListings => 'ናይ ባዕለይ ንብረታት';

  @override
  String get myListingsEmptySubtitle => 'ንምጅማር ናይ መጀመሪያ ንብረትኩም ወስኹ';
}
