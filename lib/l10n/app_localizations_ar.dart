// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سُفرة';

  @override
  String get splashTagline => 'من غزة، بكل حب';

  @override
  String get onboardingTitle1 => 'أطيب مطاعم غزة بمكان واحد';

  @override
  String get onboardingBody1 =>
      'شاورما ومشاوي وكنافة وأكثر، من المطاعم اللي بتحبها.';

  @override
  String get onboardingTitle2 => 'حدد مكانك واحنا بنوصلك';

  @override
  String get onboardingBody2 =>
      'حط دبوس على الخريطة واكتب أقرب معلم، والسائق بيعرف الطريق.';

  @override
  String get onboardingTitle3 => 'تابع طلبك لحظة بلحظة';

  @override
  String get onboardingBody3 => 'شوف طلبك وين صار، وادفع كاش عند الاستلام.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'يلا نبدأ';

  @override
  String get deliverTo => 'التوصيل إلى';

  @override
  String get greetingGuest => 'أهلًا فيك';

  @override
  String get homeHeadline => 'شو نفسك تاكل اليوم؟';

  @override
  String get searchHint => 'ابحث عن مطعم أو أكلة...';

  @override
  String get filters => 'الفلاتر';

  @override
  String get dealBadge => 'عرض الأسبوع';

  @override
  String get dealTitle => 'خصم 20٪ على أول طلب';

  @override
  String dealCode(String code) {
    return 'الكود: $code';
  }

  @override
  String get categories => 'التصنيفات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get nearYou => 'قريب منك';

  @override
  String get openNow => 'مفتوح الآن';

  @override
  String get closed => 'مسكّر';

  @override
  String minutesRange(int min, int max) {
    return '$min-$max دقيقة';
  }

  @override
  String deliveryFee(int fee) {
    return 'توصيل ₪$fee';
  }

  @override
  String get addToFavorites => 'إضافة للمفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navCart => 'السلة';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navProfile => 'حسابي';

  @override
  String get errorTitle => 'صار في مشكلة';

  @override
  String get errorBody => 'تأكد من اتصالك بالنت وجرب كمان مرة.';

  @override
  String get retry => 'حاول مرة ثانية';

  @override
  String get noResultsTitle => 'ما لقينا إشي';

  @override
  String get noResultsBody => 'جرب أكلة أو تصنيف ثاني.';

  @override
  String get favoritesEmptyTitle => 'المفضلة فاضية';

  @override
  String get favoritesEmptyBody => 'اضغط على القلب بأي مطعم عشان يضل هون.';

  @override
  String get cartEmptyTitle => 'السلة فاضية';

  @override
  String get cartEmptyBody => 'ضيف إشي طيب وبيطلع هون.';

  @override
  String get ordersEmptyTitle => 'ما في طلبات لسا';

  @override
  String get ordersEmptyBody => 'طلباتك وحالتها بتظهر هون.';

  @override
  String get browseRestaurants => 'تصفح المطاعم';

  @override
  String get guestTitle => 'بتتصفح كضيف';

  @override
  String get guestBody => 'سجل دخول عشان تحفظ عناوينك وطلباتك.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'الجهاز';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'الجهاز';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'غامق';

  @override
  String get madeInGaza => 'صُنع في غزة، بكل حب';

  @override
  String ratingsCount(int count) {
    return '$count تقييم';
  }

  @override
  String get minutesShort => 'دقيقة';

  @override
  String get deliveryLabel => 'التوصيل';

  @override
  String get minOrderLabel => 'حد أدنى';

  @override
  String price(int price) {
    return '₪$price';
  }

  @override
  String get popular => 'الأكثر طلبًا';

  @override
  String get soldOut => 'غير متوفر';

  @override
  String get share => 'مشاركة';

  @override
  String get back => 'رجوع';

  @override
  String get closedBanner => 'المطعم مسكّر هلأ، بس بتقدر تتصفح المنيو.';

  @override
  String get menuEmptyTitle => 'المنيو فاضي';

  @override
  String get menuEmptyBody => 'المطعم لسا ما ضاف أكلاته.';

  @override
  String addItem(String name) {
    return 'إضافة $name';
  }

  @override
  String get increase => 'زيادة واحد';

  @override
  String get decrease => 'إنقاص واحد';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف',
      few: '$count أصناف',
      two: 'صنفين',
      one: 'صنف واحد',
    );
    return '$_temp0';
  }

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get replaceCartTitle => 'نبلش سلة جديدة؟';

  @override
  String replaceCartBody(String restaurant) {
    return 'سلتك فيها أصناف من $restaurant. بدك نفضيها ونضيف هالصنف؟';
  }

  @override
  String get replaceCartConfirm => 'سلة جديدة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get subtotal => 'المجموع';

  @override
  String get total => 'الإجمالي';

  @override
  String get checkout => 'متابعة للدفع';

  @override
  String get clearCart => 'تفضية';

  @override
  String minOrderNotice(int amount) {
    return 'ضيف ₪$amount كمان عشان توصل للحد الأدنى';
  }

  @override
  String cartFrom(String restaurant) {
    return 'من $restaurant';
  }

  @override
  String get required => 'مطلوب';

  @override
  String get optional => 'اختياري';

  @override
  String get done => 'تمام';

  @override
  String get pickOne => 'اختار واحد';

  @override
  String pickUpTo(int count) {
    return 'اختار لحد $count';
  }

  @override
  String get noteTitle => 'ملاحظة للمطعم';

  @override
  String get noteHint => 'مثلًا: بدون بصل، حار شوي';

  @override
  String addToCartPrice(int price) {
    return 'أضف للسلة · ₪$price';
  }

  @override
  String get completeChoices => 'كمّل اختياراتك';

  @override
  String get restaurantClosed => 'المطعم مسكّر';

  @override
  String priceDelta(int price) {
    return '+₪$price';
  }

  @override
  String get close => 'إغلاق';

  @override
  String get checkoutTitle => 'إتمام الطلب';

  @override
  String get addAddress => 'أضف عنوان التوصيل';

  @override
  String get addNewAddress => 'إضافة عنوان جديد';

  @override
  String get change => 'تغيير';

  @override
  String get edit => 'تعديل';

  @override
  String get deleteAddress => 'حذف';

  @override
  String get myAddresses => 'عناويني';

  @override
  String get chooseAddress => 'اختار عنوانك';

  @override
  String get pickLocationTitle => 'حدد مكان التوصيل';

  @override
  String get pickLocationHint => 'حرّك الخريطة لحد ما الدبوس يصير على باب بيتك';

  @override
  String get confirmLocation => 'أكّد الموقع';

  @override
  String get myLocation => 'موقعي';

  @override
  String get outsideDeliveryArea => 'خارج منطقة التوصيل';

  @override
  String get outsideDeliveryAreaBody => 'حاليًا بنوصل داخل قطاع غزة بس.';

  @override
  String get locationDenied => 'إذن الموقع مسكّر، بس بتقدر تحرك الخريطة بإيدك.';

  @override
  String get locationDisabled => 'شغّل خدمة الموقع عشان نلاقيك أسرع.';

  @override
  String get locationOutside =>
      'شكلك برا غزة، حرّك الخريطة للمكان اللي بدك الطلب يوصله.';

  @override
  String get locationFailed => 'ما قدرنا نجيب موقعك، حرّك الخريطة بإيدك.';

  @override
  String get addressDetailsTitle => 'تفاصيل العنوان';

  @override
  String get labelHome => 'البيت';

  @override
  String get labelWork => 'الشغل';

  @override
  String get labelOther => 'غير';

  @override
  String get landmarkLabel => 'أقرب معلم';

  @override
  String get landmarkHint => 'مثلًا: قرب مسجد العمري، مقابل الصيدلية';

  @override
  String get landmarkRequired => 'ضيف معلم عشان السائق يلاقيك';

  @override
  String get detailsLabel => 'الشارع، العمارة، الطابق';

  @override
  String get phoneLabel => 'رقم الجوال';

  @override
  String get phoneInvalid => 'اكتب رقم جوال صحيح (059 أو 056)';

  @override
  String get saveAddress => 'احفظ العنوان';

  @override
  String get changeLocation => 'غيّر الموقع';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cashOnDelivery => 'كاش عند الاستلام';

  @override
  String get cashOnDeliveryHint => 'ادفع للسائق لما يوصلك الطلب';

  @override
  String get eWallet => 'محفظة إلكترونية';

  @override
  String get soon => 'قريبًا';

  @override
  String get promoTitle => 'كود الخصم';

  @override
  String get promoHint => 'اكتب الكود';

  @override
  String get apply => 'تطبيق';

  @override
  String get promoInvalid => 'الكود هاد مش صحيح';

  @override
  String get discount => 'الخصم';

  @override
  String get remove => 'إزالة';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String placeOrder(int price) {
    return 'تأكيد الطلب · ₪$price';
  }

  @override
  String get chooseAddressFirst => 'اختار عنوان أول';

  @override
  String deliveryEta(int min, int max) {
    return 'بيوصل خلال $min-$max دقيقة';
  }

  @override
  String get orderPlacedTitle => 'وصلنا طلبك!';

  @override
  String orderPlacedBody(String restaurant) {
    return '$restaurant بلّش يجهزه.';
  }

  @override
  String orderNumber(int id) {
    return 'طلب رقم $id';
  }

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get backToHome => 'رجوع للرئيسية';

  @override
  String get statusPlaced => 'تم استلام الطلب';

  @override
  String get statusPreparing => 'قيد التحضير';

  @override
  String get statusOnTheWay => 'بالطريق';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get placeOrderFailed => 'ما قدرنا نبعت طلبك، جرب كمان مرة.';

  @override
  String get statusPlacedBody => 'المطعم استلم طلبك';

  @override
  String statusPreparingBody(String restaurant) {
    return '$restaurant بيجهز أكلك';
  }

  @override
  String get statusOnTheWayBody => 'السائق بالطريق إليك';

  @override
  String get statusDeliveredTitle => 'بالهنا والعافية!';

  @override
  String get statusDeliveredBody => 'وصلك طلبك';

  @override
  String get arrivesIn => 'بيوصل خلال';

  @override
  String minutesCount(int count) {
    return '$count دقيقة';
  }

  @override
  String get stepPlaced => 'تم الطلب';

  @override
  String get stepPreparing => 'التحضير';

  @override
  String get stepOnTheWay => 'بالطريق';

  @override
  String get stepDelivered => 'وصل';

  @override
  String get rider => 'سائق سُفرة';

  @override
  String get riderOnTheWay => 'جايبلك طلبك';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get reorder => 'اطلب مرة ثانية';

  @override
  String get restaurantLocation => 'الموقع';

  @override
  String demoTimeNote(int times) {
    return 'تجريبي: الوقت ماشي أسرع $times مرة';
  }

  @override
  String get sortBy => 'رتّب حسب';

  @override
  String get sortRecommended => 'الأنسب';

  @override
  String get sortNearest => 'الأقرب';

  @override
  String get sortRating => 'الأعلى تقييمًا';

  @override
  String get sortFastest => 'الأسرع توصيلًا';

  @override
  String get sortDeliveryFee => 'أرخص توصيل';

  @override
  String get filterOpenOnly => 'المفتوح الآن بس';

  @override
  String get filterTopRated => 'تقييم 4.5 وأعلى';

  @override
  String get filterCheapDelivery => 'توصيل ₪4 أو أقل';

  @override
  String get showOnly => 'اعرض بس';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String showResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اعرض $count مطعم',
      few: 'اعرض $count مطاعم',
      two: 'اعرض مطعمين',
      one: 'اعرض مطعم واحد',
      zero: 'ما في مطاعم بهالفلاتر',
    );
    return '$_temp0';
  }

  @override
  String distanceKm(String km) {
    return '$km كم';
  }

  @override
  String get distanceFromAddress => 'المسافة من عنوانك';

  @override
  String get distanceFromCenter => 'ضيف عنوانك عشان المسافة تكون أدق';

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get email => 'الإيميل';

  @override
  String get password => 'كلمة السر';

  @override
  String get emailInvalid => 'اكتب إيميل صحيح';

  @override
  String get passwordTooShort => '8 أحرف على الأقل';

  @override
  String get haveAccount => 'عندك حساب؟ سجل دخول';

  @override
  String get noAccount => 'جديد؟ أنشئ حساب';

  @override
  String get signInToOrder => 'سجل دخول عشان تكمل الطلب';

  @override
  String get signInAndOrder => 'سجل دخول وكمّل';

  @override
  String get signInBenefit => 'عناوينك وطلباتك بتضل معك على أي جوال.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signedIn => 'مسجل دخول';

  @override
  String get authInvalidCredentials => 'الإيميل أو كلمة السر غلط';

  @override
  String get authEmailNotConfirmed => 'أكّد إيميلك أول، وبعدين سجل دخول';

  @override
  String get authUserExists => 'هاد الإيميل إله حساب، سجل دخول بداله.';

  @override
  String get authWeakPassword => 'اختار كلمة سر أقوى';

  @override
  String get authCheckEmail =>
      'بعتنالك رابط تأكيد على الإيميل، افتحه وبعدين سجل دخول.';

  @override
  String get authFailed => 'ما قدرنا نوصل للسيرفر، تأكد من النت.';

  @override
  String get demoMode => 'وضع تجريبي: اربط Supabase عشان تشتغل الحسابات';

  @override
  String get showPassword => 'إظهار كلمة السر';

  @override
  String get hidePassword => 'إخفاء كلمة السر';

  @override
  String shareRestaurant(String name, String cuisine, String area) {
    return 'جرّب $name على سُفرة: $cuisine في $area 🍽️';
  }
}
