// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sufra';

  @override
  String get splashTagline => 'From Gaza, with love';

  @override
  String get onboardingTitle1 => 'Gaza\'s best kitchens, in one app';

  @override
  String get onboardingBody1 =>
      'Shawarma, grills, knafeh and more from the restaurants you love.';

  @override
  String get onboardingTitle2 => 'Pin it, we\'ll find you';

  @override
  String get onboardingBody2 =>
      'Drop a pin on the map and add a landmark. Our riders know the way.';

  @override
  String get onboardingTitle3 => 'Track every step';

  @override
  String get onboardingBody3 =>
      'Follow your order live and pay cash on delivery.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Let\'s eat';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get greetingGuest => 'Hey there';

  @override
  String get homeHeadline => 'What are you craving today?';

  @override
  String get searchHint => 'Search restaurants or dishes...';

  @override
  String get filters => 'Filters';

  @override
  String get dealBadge => 'Deal of the week';

  @override
  String get dealTitle => '20% off your first order';

  @override
  String dealCode(String code) {
    return 'Code: $code';
  }

  @override
  String get categories => 'Categories';

  @override
  String get seeAll => 'See all';

  @override
  String get nearYou => 'Near you';

  @override
  String get openNow => 'Open now';

  @override
  String get closed => 'Closed';

  @override
  String minutesRange(int min, int max) {
    return '$min–$max min';
  }

  @override
  String deliveryFee(int fee) {
    return '₪$fee delivery';
  }

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorBody => 'Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get noResultsTitle => 'No matches';

  @override
  String get noResultsBody => 'Try another dish or category.';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on any restaurant to keep it here.';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody => 'Add something tasty and it will show up here.';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyBody =>
      'Your orders and their status will appear here.';

  @override
  String get browseRestaurants => 'Browse restaurants';

  @override
  String get guestTitle => 'Browsing as a guest';

  @override
  String get guestBody => 'Sign in to save your addresses and orders.';

  @override
  String get signIn => 'Sign in';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get madeInGaza => 'Made in Gaza, with love';

  @override
  String ratingsCount(int count) {
    return '$count ratings';
  }

  @override
  String get minutesShort => 'min';

  @override
  String get deliveryLabel => 'Delivery';

  @override
  String get minOrderLabel => 'Min. order';

  @override
  String price(int price) {
    return '₪$price';
  }

  @override
  String get popular => 'Popular';

  @override
  String get soldOut => 'Sold out';

  @override
  String get share => 'Share';

  @override
  String get back => 'Back';

  @override
  String get closedBanner => 'Closed right now. You can still browse the menu.';

  @override
  String get menuEmptyTitle => 'No menu yet';

  @override
  String get menuEmptyBody => 'This restaurant hasn\'t added its dishes yet.';

  @override
  String addItem(String name) {
    return 'Add $name';
  }

  @override
  String get increase => 'One more';

  @override
  String get decrease => 'One less';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get viewCart => 'View cart';

  @override
  String get replaceCartTitle => 'Start a new cart?';

  @override
  String replaceCartBody(String restaurant) {
    return 'Your cart has items from $restaurant. Clear it and add this dish?';
  }

  @override
  String get replaceCartConfirm => 'New cart';

  @override
  String get cancel => 'Cancel';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Checkout';

  @override
  String get clearCart => 'Clear';

  @override
  String minOrderNotice(int amount) {
    return 'Add ₪$amount more to reach the minimum order';
  }

  @override
  String cartFrom(String restaurant) {
    return 'From $restaurant';
  }

  @override
  String get required => 'Required';

  @override
  String get optional => 'Optional';

  @override
  String get done => 'Done';

  @override
  String get pickOne => 'Pick one';

  @override
  String pickUpTo(int count) {
    return 'Pick up to $count';
  }

  @override
  String get noteTitle => 'Note for the restaurant';

  @override
  String get noteHint => 'e.g. no onions, a little spicy';

  @override
  String addToCartPrice(int price) {
    return 'Add to cart · ₪$price';
  }

  @override
  String get completeChoices => 'Complete your choices';

  @override
  String get restaurantClosed => 'Restaurant is closed';

  @override
  String priceDelta(int price) {
    return '+₪$price';
  }

  @override
  String get close => 'Close';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get addAddress => 'Add delivery address';

  @override
  String get addNewAddress => 'Add a new address';

  @override
  String get change => 'Change';

  @override
  String get edit => 'Edit';

  @override
  String get deleteAddress => 'Delete';

  @override
  String get myAddresses => 'My addresses';

  @override
  String get chooseAddress => 'Choose your address';

  @override
  String get pickLocationTitle => 'Set delivery location';

  @override
  String get pickLocationHint => 'Move the map until the pin sits on your door';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get myLocation => 'My location';

  @override
  String get outsideDeliveryArea => 'Outside our delivery area';

  @override
  String get outsideDeliveryAreaBody =>
      'We deliver inside the Gaza Strip for now.';

  @override
  String get locationDenied =>
      'Location permission is off. You can still move the map by hand.';

  @override
  String get locationDisabled =>
      'Turn on location services so we can find you faster.';

  @override
  String get locationOutside =>
      'You seem to be outside Gaza. Move the map to where you\'d like your order.';

  @override
  String get locationFailed =>
      'We couldn\'t get your location. Move the map by hand.';

  @override
  String get addressDetailsTitle => 'Address details';

  @override
  String get labelHome => 'Home';

  @override
  String get labelWork => 'Work';

  @override
  String get labelOther => 'Other';

  @override
  String get landmarkLabel => 'Nearest landmark';

  @override
  String get landmarkHint => 'e.g. near Al-Omari mosque, opposite the pharmacy';

  @override
  String get landmarkRequired => 'Add a landmark so the rider finds you';

  @override
  String get detailsLabel => 'Street, building, floor';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get phoneInvalid => 'Enter a valid mobile number (059 or 056)';

  @override
  String get saveAddress => 'Save address';

  @override
  String get changeLocation => 'Change location';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cashOnDelivery => 'Cash on delivery';

  @override
  String get cashOnDeliveryHint => 'Pay the rider when your order arrives';

  @override
  String get eWallet => 'E-wallet';

  @override
  String get soon => 'Soon';

  @override
  String get promoTitle => 'Promo code';

  @override
  String get promoHint => 'Enter code';

  @override
  String get apply => 'Apply';

  @override
  String get promoInvalid => 'This code isn\'t valid';

  @override
  String get discount => 'Discount';

  @override
  String get remove => 'Remove';

  @override
  String get orderSummary => 'Order summary';

  @override
  String placeOrder(int price) {
    return 'Place order · ₪$price';
  }

  @override
  String get chooseAddressFirst => 'Choose an address first';

  @override
  String deliveryEta(int min, int max) {
    return 'Arrives in $min-$max min';
  }

  @override
  String get orderPlacedTitle => 'Order received!';

  @override
  String orderPlacedBody(String restaurant) {
    return '$restaurant is getting it ready.';
  }

  @override
  String orderNumber(int id) {
    return 'Order #$id';
  }

  @override
  String get trackOrder => 'Track order';

  @override
  String get backToHome => 'Back to home';

  @override
  String get statusPlaced => 'Received';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusOnTheWay => 'On the way';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get placeOrderFailed => 'We couldn\'t place your order. Try again.';

  @override
  String get statusPlacedBody => 'The restaurant got your order';

  @override
  String statusPreparingBody(String restaurant) {
    return '$restaurant is preparing your food';
  }

  @override
  String get statusOnTheWayBody => 'Your rider is on the way';

  @override
  String get statusDeliveredTitle => 'Enjoy your meal!';

  @override
  String get statusDeliveredBody => 'Your order was delivered';

  @override
  String get arrivesIn => 'Arrives in';

  @override
  String minutesCount(int count) {
    return '$count min';
  }

  @override
  String get stepPlaced => 'Placed';

  @override
  String get stepPreparing => 'Preparing';

  @override
  String get stepOnTheWay => 'On the way';

  @override
  String get stepDelivered => 'Delivered';

  @override
  String get rider => 'Sufra rider';

  @override
  String get riderOnTheWay => 'Bringing your order';

  @override
  String get orderDetails => 'Order details';

  @override
  String get reorder => 'Order again';

  @override
  String get restaurantLocation => 'Location';

  @override
  String demoTimeNote(int times) {
    return 'Demo: time runs $times× faster';
  }

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortNearest => 'Nearest';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortFastest => 'Fastest delivery';

  @override
  String get sortDeliveryFee => 'Lowest delivery fee';

  @override
  String get filterOpenOnly => 'Open now only';

  @override
  String get filterTopRated => 'Rated 4.5+';

  @override
  String get filterCheapDelivery => 'Delivery ₪4 or less';

  @override
  String get showOnly => 'Show only';

  @override
  String get reset => 'Reset';

  @override
  String showResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count restaurants',
      one: 'Show 1 restaurant',
      zero: 'No restaurants match',
    );
    return '$_temp0';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get distanceFromAddress => 'Distances from your address';

  @override
  String get distanceFromCenter => 'Add your address for exact distances';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordTooShort => 'At least 8 characters';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get noAccount => 'New here? Create an account';

  @override
  String get signInToOrder => 'Sign in to place your order';

  @override
  String get signInAndOrder => 'Sign in to continue';

  @override
  String get signInBenefit =>
      'Your addresses and orders follow you to any phone.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signedIn => 'Signed in';

  @override
  String get authInvalidCredentials => 'Wrong email or password';

  @override
  String get authEmailNotConfirmed => 'Confirm your email first, then sign in';

  @override
  String get authUserExists =>
      'This email already has an account. Sign in instead.';

  @override
  String get authWeakPassword => 'Choose a stronger password';

  @override
  String get authCheckEmail =>
      'We sent you a confirmation link. Open it, then sign in.';

  @override
  String get authFailed => 'Couldn\'t reach the server. Check your connection.';

  @override
  String get demoMode => 'Demo mode: connect Supabase to turn on accounts';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String shareRestaurant(String name, String cuisine, String area) {
    return 'Try $name on Sufra: $cuisine in $area 🍽️';
  }
}
