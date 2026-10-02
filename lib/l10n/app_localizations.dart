import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sufra'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'From Gaza, with love'**
  String get splashTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Gaza\'s best kitchens, in one app'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Shawarma, grills, knafeh and more from the restaurants you love.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Pin it, we\'ll find you'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Drop a pin on the map and add a landmark. Our riders know the way.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track every step'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Follow your order live and pay cash on delivery.'**
  String get onboardingBody3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s eat'**
  String get getStarted;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @greetingGuest.
  ///
  /// In en, this message translates to:
  /// **'Hey there'**
  String get greetingGuest;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'What are you craving today?'**
  String get homeHeadline;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants or dishes...'**
  String get searchHint;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @dealBadge.
  ///
  /// In en, this message translates to:
  /// **'Deal of the week'**
  String get dealBadge;

  /// No description provided for @dealTitle.
  ///
  /// In en, this message translates to:
  /// **'20% off your first order'**
  String get dealTitle;

  /// No description provided for @dealCode.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String dealCode(String code);

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get nearYou;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @minutesRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} min'**
  String minutesRange(int min, int max);

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'₪{fee} delivery'**
  String deliveryFee(int fee);

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another dish or category.'**
  String get noResultsBody;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any restaurant to keep it here.'**
  String get favoritesEmptyBody;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add something tasty and it will show up here.'**
  String get cartEmptyBody;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your orders and their status will appear here.'**
  String get ordersEmptyBody;

  /// No description provided for @browseRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Browse restaurants'**
  String get browseRestaurants;

  /// No description provided for @guestTitle.
  ///
  /// In en, this message translates to:
  /// **'Browsing as a guest'**
  String get guestTitle;

  /// No description provided for @guestBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your addresses and orders.'**
  String get guestBody;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get languageSystem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @madeInGaza.
  ///
  /// In en, this message translates to:
  /// **'Made in Gaza, with love'**
  String get madeInGaza;

  /// No description provided for @ratingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String ratingsCount(int count);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @deliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryLabel;

  /// No description provided for @minOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Min. order'**
  String get minOrderLabel;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'₪{price}'**
  String price(int price);

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @closedBanner.
  ///
  /// In en, this message translates to:
  /// **'Closed right now. You can still browse the menu.'**
  String get closedBanner;

  /// No description provided for @menuEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No menu yet'**
  String get menuEmptyTitle;

  /// No description provided for @menuEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'This restaurant hasn\'t added its dishes yet.'**
  String get menuEmptyBody;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addItem(String name);

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'One less'**
  String get decrease;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @replaceCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new cart?'**
  String get replaceCartTitle;

  /// No description provided for @replaceCartBody.
  ///
  /// In en, this message translates to:
  /// **'Your cart has items from {restaurant}. Clear it and add this dish?'**
  String replaceCartBody(String restaurant);

  /// No description provided for @replaceCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'New cart'**
  String get replaceCartConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearCart;

  /// No description provided for @minOrderNotice.
  ///
  /// In en, this message translates to:
  /// **'Add ₪{amount} more to reach the minimum order'**
  String minOrderNotice(int amount);

  /// No description provided for @cartFrom.
  ///
  /// In en, this message translates to:
  /// **'From {restaurant}'**
  String cartFrom(String restaurant);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pickOne.
  ///
  /// In en, this message translates to:
  /// **'Pick one'**
  String get pickOne;

  /// No description provided for @pickUpTo.
  ///
  /// In en, this message translates to:
  /// **'Pick up to {count}'**
  String pickUpTo(int count);

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note for the restaurant'**
  String get noteTitle;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. no onions, a little spicy'**
  String get noteHint;

  /// No description provided for @addToCartPrice.
  ///
  /// In en, this message translates to:
  /// **'Add to cart · ₪{price}'**
  String addToCartPrice(int price);

  /// No description provided for @completeChoices.
  ///
  /// In en, this message translates to:
  /// **'Complete your choices'**
  String get completeChoices;

  /// No description provided for @restaurantClosed.
  ///
  /// In en, this message translates to:
  /// **'Restaurant is closed'**
  String get restaurantClosed;

  /// No description provided for @priceDelta.
  ///
  /// In en, this message translates to:
  /// **'+₪{price}'**
  String priceDelta(int price);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add delivery address'**
  String get addAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add a new address'**
  String get addNewAddress;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAddress;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get myAddresses;

  /// No description provided for @chooseAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose your address'**
  String get chooseAddress;

  /// No description provided for @pickLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set delivery location'**
  String get pickLocationTitle;

  /// No description provided for @pickLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map until the pin sits on your door'**
  String get pickLocationHint;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @outsideDeliveryArea.
  ///
  /// In en, this message translates to:
  /// **'Outside our delivery area'**
  String get outsideDeliveryArea;

  /// No description provided for @outsideDeliveryAreaBody.
  ///
  /// In en, this message translates to:
  /// **'We deliver inside the Gaza Strip for now.'**
  String get outsideDeliveryAreaBody;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is off. You can still move the map by hand.'**
  String get locationDenied;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services so we can find you faster.'**
  String get locationDisabled;

  /// No description provided for @locationOutside.
  ///
  /// In en, this message translates to:
  /// **'You seem to be outside Gaza. Move the map to where you\'d like your order.'**
  String get locationOutside;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get your location. Move the map by hand.'**
  String get locationFailed;

  /// No description provided for @addressDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Address details'**
  String get addressDetailsTitle;

  /// No description provided for @labelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelHome;

  /// No description provided for @labelWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get labelWork;

  /// No description provided for @labelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelOther;

  /// No description provided for @landmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Nearest landmark'**
  String get landmarkLabel;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. near Al-Omari mosque, opposite the pharmacy'**
  String get landmarkHint;

  /// No description provided for @landmarkRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a landmark so the rider finds you'**
  String get landmarkRequired;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Street, building, floor'**
  String get detailsLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number (059 or 056)'**
  String get phoneInvalid;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddress;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get changeLocation;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDelivery;

  /// No description provided for @cashOnDeliveryHint.
  ///
  /// In en, this message translates to:
  /// **'Pay the rider when your order arrives'**
  String get cashOnDeliveryHint;

  /// No description provided for @eWallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallet'**
  String get eWallet;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @promoTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get promoTitle;

  /// No description provided for @promoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get promoHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @promoInvalid.
  ///
  /// In en, this message translates to:
  /// **'This code isn\'t valid'**
  String get promoInvalid;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order · ₪{price}'**
  String placeOrder(int price);

  /// No description provided for @chooseAddressFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose an address first'**
  String get chooseAddressFirst;

  /// No description provided for @deliveryEta.
  ///
  /// In en, this message translates to:
  /// **'Arrives in {min}-{max} min'**
  String deliveryEta(int min, int max);

  /// No description provided for @orderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order received!'**
  String get orderPlacedTitle;

  /// No description provided for @orderPlacedBody.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} is getting it ready.'**
  String orderPlacedBody(String restaurant);

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(int id);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @statusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusPlaced;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get statusOnTheWay;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @placeOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t place your order. Try again.'**
  String get placeOrderFailed;

  /// No description provided for @statusPlacedBody.
  ///
  /// In en, this message translates to:
  /// **'The restaurant got your order'**
  String get statusPlacedBody;

  /// No description provided for @statusPreparingBody.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} is preparing your food'**
  String statusPreparingBody(String restaurant);

  /// No description provided for @statusOnTheWayBody.
  ///
  /// In en, this message translates to:
  /// **'Your rider is on the way'**
  String get statusOnTheWayBody;

  /// No description provided for @statusDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your meal!'**
  String get statusDeliveredTitle;

  /// No description provided for @statusDeliveredBody.
  ///
  /// In en, this message translates to:
  /// **'Your order was delivered'**
  String get statusDeliveredBody;

  /// No description provided for @arrivesIn.
  ///
  /// In en, this message translates to:
  /// **'Arrives in'**
  String get arrivesIn;

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesCount(int count);

  /// No description provided for @stepPlaced.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get stepPlaced;

  /// No description provided for @stepPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get stepPreparing;

  /// No description provided for @stepOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get stepOnTheWay;

  /// No description provided for @stepDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get stepDelivered;

  /// No description provided for @rider.
  ///
  /// In en, this message translates to:
  /// **'Sufra rider'**
  String get rider;

  /// No description provided for @riderOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Bringing your order'**
  String get riderOnTheWay;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Order again'**
  String get reorder;

  /// No description provided for @restaurantLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get restaurantLocation;

  /// No description provided for @demoTimeNote.
  ///
  /// In en, this message translates to:
  /// **'Demo: time runs {times}× faster'**
  String demoTimeNote(int times);

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortNearest;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortRating;

  /// No description provided for @sortFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest delivery'**
  String get sortFastest;

  /// No description provided for @sortDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Lowest delivery fee'**
  String get sortDeliveryFee;

  /// No description provided for @filterOpenOnly.
  ///
  /// In en, this message translates to:
  /// **'Open now only'**
  String get filterOpenOnly;

  /// No description provided for @filterTopRated.
  ///
  /// In en, this message translates to:
  /// **'Rated 4.5+'**
  String get filterTopRated;

  /// No description provided for @filterCheapDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery ₪4 or less'**
  String get filterCheapDelivery;

  /// No description provided for @showOnly.
  ///
  /// In en, this message translates to:
  /// **'Show only'**
  String get showOnly;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No restaurants match} =1{Show 1 restaurant} other{Show {count} restaurants}}'**
  String showResults(int count);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// No description provided for @distanceFromAddress.
  ///
  /// In en, this message translates to:
  /// **'Distances from your address'**
  String get distanceFromAddress;

  /// No description provided for @distanceFromCenter.
  ///
  /// In en, this message translates to:
  /// **'Add your address for exact distances'**
  String get distanceFromCenter;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccount;

  /// No description provided for @signInToOrder.
  ///
  /// In en, this message translates to:
  /// **'Sign in to place your order'**
  String get signInToOrder;

  /// No description provided for @signInAndOrder.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInAndOrder;

  /// No description provided for @signInBenefit.
  ///
  /// In en, this message translates to:
  /// **'Your addresses and orders follow you to any phone.'**
  String get signInBenefit;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email first, then sign in'**
  String get authEmailNotConfirmed;

  /// No description provided for @authUserExists.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account. Sign in instead.'**
  String get authUserExists;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password'**
  String get authWeakPassword;

  /// No description provided for @authCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'We sent you a confirmation link. Open it, then sign in.'**
  String get authCheckEmail;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your connection.'**
  String get authFailed;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: connect Supabase to turn on accounts'**
  String get demoMode;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @shareRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Try {name} on Sufra: {cuisine} in {area} 🍽️'**
  String shareRestaurant(String name, String cuisine, String area);
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
