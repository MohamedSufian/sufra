import '../domain/models.dart';

// Sample menus for the fake repository. Dishes are typical of Gaza; prices are illustrative.

// Plate art indexes: 0 grill, 1 knafeh, 2 falafel, 3 seafood, 4 pizza, 5 shawarma.

MenuSection _s(String id, String ar, String en) => MenuSection(id: id, name: LocalizedText(ar: ar, en: en));

OptionChoice _c(String id, String ar, String en, [int priceDelta = 0]) =>
    OptionChoice(id: id, name: LocalizedText(ar: ar, en: en), priceDelta: priceDelta);

/// Choice ids get the group id as a prefix so they stay unique within a dish.
OptionGroup _g(String id, String ar, String en, List<OptionChoice> choices, {bool required = false, int max = 1}) =>
    OptionGroup(
      id: id,
      name: LocalizedText(ar: ar, en: en),
      isRequired: required,
      maxSelections: max,
      choices: [for (final c in choices) OptionChoice(id: '$id.${c.id}', name: c.name, priceDelta: c.priceDelta)],
    );

// Groups shared by several dishes.
final _grillSize = _g('size', 'الحجم', 'Size', required: true, [
  _c('regular', 'وجبة فردية', 'Single meal'),
  _c('family', 'وجبة عائلية', 'Family meal', 40),
]);
final _grillExtras = _g('extras', 'إضافات', 'Extras', max: 3, [
  _c('bread', 'خبز طابون زيادة', 'Extra taboon bread', 2),
  _c('toum', 'ثومية زيادة', 'Extra garlic sauce', 2),
  _c('fries', 'بطاطا', 'Fries', 6),
]);
final _bread = _g('bread', 'نوع الخبز', 'Bread', required: true, [
  _c('saj', 'صاج', 'Saj'),
  _c('kmaj', 'كماج', 'Kmaj'),
  _c('taboon', 'طابون', 'Taboon', 1),
]);
final _sandwichExtras = _g('extras', 'إضافات', 'Extras', max: 3, [
  _c('cheese', 'جبنة', 'Cheese', 3),
  _c('toum', 'ثومية زيادة', 'Extra garlic sauce', 1),
  _c('spicy', 'حار', 'Spicy'),
]);
final _pizzaSize = _g('size', 'الحجم', 'Size', required: true, [
  _c('medium', 'وسط', 'Medium'),
  _c('large', 'كبير', 'Large', 10),
  _c('family', 'عائلي', 'Family', 20),
]);
final _pizzaExtras = _g('extras', 'إضافات', 'Toppings', max: 3, [
  _c('cheese', 'جبنة زيادة', 'Extra cheese', 5),
  _c('olives', 'زيتون', 'Olives', 2),
  _c('mushroom', 'فطر', 'Mushrooms', 3),
]);

Product Function(String id, String ar, String en, String descAr, String descEn, int price, int art,
    {bool popular, bool available, List<OptionGroup> options}) _menuOf(String restaurantId, String sectionId) =>
    (id, ar, en, descAr, descEn, price, art, {popular = false, available = true, options = const []}) => Product(
      id: '$restaurantId.$id',
      restaurantId: restaurantId,
      sectionId: sectionId,
      name: LocalizedText(ar: ar, en: en),
      description: LocalizedText(ar: descAr, en: descEn),
      price: price,
      artIndex: art,
      isPopular: popular,
      isAvailable: available,
      optionGroups: options,
    );

final fakeMenus = <String, RestaurantMenu>{
  'bahr-grill': () {
    final grill = _menuOf('bahr-grill', 'grill');
    final sandwiches = _menuOf('bahr-grill', 'sandwiches');
    final starters = _menuOf('bahr-grill', 'starters');
    final drinks = _menuOf('bahr-grill', 'drinks');
    return RestaurantMenu(
      sections: [
        _s('grill', 'مشاوي', 'Grills'),
        _s('sandwiches', 'سندويشات', 'Sandwiches'),
        _s('starters', 'مقبلات', 'Starters'),
        _s('drinks', 'مشروبات', 'Drinks'),
      ],
      products: [
        grill('mix', 'مشكل مشاوي', 'Mixed grill', 'كباب وشيش طاووق وكفتة مع خبز طابون وسلطة', 'Kebab, shish tawook and kofta with taboon bread and salad', 45, 0, popular: true, options: [_grillSize, _grillExtras]),
        grill('kebab', 'كباب لحمة', 'Lamb kebab', 'سيخين كباب على الفحم مع بصل وبقدونس', 'Two charcoal kebab skewers with onion and parsley', 35, 0),
        grill('tawook', 'شيش طاووق', 'Shish tawook', 'صدر دجاج متبل بالثوم والليمون', 'Chicken breast marinated in garlic and lemon', 30, 5, popular: true, options: [
          _g('size', 'الكمية', 'Portion', required: true, [_c('meal', 'وجبة', 'Meal'), _c('half-kilo', 'نص كيلو', 'Half kilo', 15)]),
          _grillExtras,
        ]),
        grill('ribs', 'ريش غنم', 'Lamb chops', 'ريش غنم بلدي على الفحم', 'Charcoal-grilled local lamb chops', 55, 0, available: false),
        sandwiches('tawook-sandwich', 'سندويش شيش طاووق', 'Shish tawook sandwich', 'مع ثومية ومخلل وبطاطا', 'With garlic sauce, pickles and fries', 15, 5, popular: true, options: [_bread, _sandwichExtras]),
        sandwiches('kofta-sandwich', 'سندويش كفتة', 'Kofta sandwich', 'كفتة مشوية مع طحينة وبندورة', 'Grilled kofta with tahini and tomato', 14, 0),
        sandwiches('shawarma-arabi', 'شاورما عربي', 'Arabi shawarma', 'شاورما دجاج مقطعة مع ثومية وبطاطا', 'Sliced chicken shawarma with garlic sauce and fries', 18, 5, options: [
          _g('size', 'الحجم', 'Size', required: true, [_c('regular', 'عادي', 'Regular'), _c('double', 'دبل', 'Double', 8)]),
        ]),
        starters('hummus', 'حمص', 'Hummus', 'حمص بالطحينة وزيت زيتون', 'Hummus with tahini and olive oil', 8, 2),
        starters('mutabbal', 'متبل', 'Mutabbal', 'باذنجان مشوي بالطحينة', 'Smoky eggplant with tahini', 8, 2),
        starters('salad', 'سلطة عربية', 'Arabic salad', 'بندورة وخيار وبقدونس وليمون', 'Tomato, cucumber, parsley and lemon', 7, 2),
        starters('fries', 'بطاطا مقلية', 'Fries', '', '', 6, 4),
        drinks('lemon-mint', 'ليمون بالنعنع', 'Lemon mint', 'طازة ومثلجة', 'Fresh and iced', 6, 2),
        drinks('cola', 'كولا', 'Cola', '', '', 4, 3),
      ],
    );
  }(),
  'rimal-knafeh': () {
    final knafeh = _menuOf('rimal-knafeh', 'knafeh');
    final sweets = _menuOf('rimal-knafeh', 'sweets');
    final drinks = _menuOf('rimal-knafeh', 'drinks');
    return RestaurantMenu(
      sections: [
        _s('knafeh', 'كنافة', 'Knafeh'),
        _s('sweets', 'حلويات', 'Sweets'),
        _s('drinks', 'مشروبات', 'Drinks'),
      ],
      products: [
        knafeh('nabulsi', 'كنافة نابلسية', 'Nabulsi knafeh', 'جبنة نابلسية سايحة وقطر، صحن فردي', 'Melted Nabulsi cheese and syrup, single plate', 12, 1, popular: true, options: [
          _g('size', 'الكمية', 'Amount', required: true, [
            _c('plate', 'صحن فردي', 'Single plate'),
            _c('quarter', 'ربع كيلو', 'Quarter kilo', 8),
            _c('half', 'نص كيلو', 'Half kilo', 20),
          ]),
          _g('extras', 'إضافات', 'Extras', max: 2, [_c('pistachio', 'فستق حلبي', 'Pistachio', 4), _c('qashta', 'قشطة', 'Qashta cream', 3)]),
        ]),
        knafeh('khishneh', 'كنافة خشنة', 'Coarse knafeh', 'عجينة خشنة مقرمشة بالسمنة البلدي', 'Crunchy coarse dough with local ghee', 12, 1),
        knafeh('naameh', 'كنافة ناعمة', 'Fine knafeh', 'ناعمة ومحمرة بالقطر', 'Smooth and golden with syrup', 12, 1),
        sweets('baklava', 'بقلاوة مشكلة', 'Mixed baklava', 'نص كيلو، فستق وجوز', 'Half a kilo, pistachio and walnut', 25, 1, popular: true),
        sweets('harisseh', 'هريسة', 'Harisseh', 'سميد وجوز الهند بالقطر', 'Semolina and coconut cake with syrup', 15, 4),
        sweets('qatayef', 'قطايف', 'Qatayef', 'بالجوز أو بالجبنة، موسمية', 'Walnut or cheese, seasonal', 20, 1, available: false),
        drinks('coffee', 'قهوة عربية', 'Arabic coffee', 'بالهيل', 'With cardamom', 5, 2, options: [
          _g('sugar', 'السكر', 'Sugar', required: true, [_c('plain', 'سادة', 'No sugar'), _c('medium', 'وسط', 'Medium'), _c('sweet', 'حلوة', 'Sweet')]),
        ]),
        drinks('tea', 'شاي بالمرمية', 'Sage tea', '', '', 3, 2),
      ],
    );
  }(),
  'shati-falafel': () {
    final sandwiches = _menuOf('shati-falafel', 'sandwiches');
    final plates = _menuOf('shati-falafel', 'plates');
    return RestaurantMenu(
      sections: [
        _s('sandwiches', 'سندويشات', 'Sandwiches'),
        _s('plates', 'صحون', 'Plates'),
      ],
      products: [
        sandwiches('falafel', 'سندويش فلافل', 'Falafel sandwich', 'فلافل سخنة مع طحينة وسلطة', 'Hot falafel with tahini and salad', 4, 2, popular: true),
        sandwiches('falafel-eggplant', 'فلافل مع باذنجان', 'Falafel with eggplant', 'فلافل وباذنجان مقلي وبطاطا', 'Falafel, fried eggplant and fries', 6, 2),
        plates('foul', 'صحن فول', 'Foul plate', 'فول مدمس بالليمون والزيت', 'Fava beans with lemon and oil', 7, 2, popular: true),
        plates('hummus', 'صحن حمص', 'Hummus plate', '', '', 7, 2),
        plates('falafel-dozen', 'فلافل (12 حبة)', 'Falafel (12 pieces)', '', '', 6, 2),
      ],
    );
  }(),
  'saha-shawarma': () {
    final shawarma = _menuOf('saha-shawarma', 'shawarma');
    final meals = _menuOf('saha-shawarma', 'meals');
    return RestaurantMenu(
      sections: [
        _s('shawarma', 'شاورما', 'Shawarma'),
        _s('meals', 'وجبات', 'Meals'),
      ],
      products: [
        shawarma('chicken', 'سندويش شاورما دجاج', 'Chicken shawarma sandwich', 'بخبز الصاج مع ثومية ومخلل', 'In saj bread with garlic sauce and pickles', 12, 5, popular: true, options: [
          _g('size', 'الحجم', 'Size', required: true, [_c('regular', 'عادي', 'Regular'), _c('super', 'سوبر', 'Super', 5)]),
          _sandwichExtras,
        ]),
        shawarma('arabi', 'شاورما عربي', 'Arabi shawarma', 'مقطعة مع بطاطا وثومية', 'Sliced, with fries and garlic sauce', 18, 5),
        meals('plate', 'صحن شاورما', 'Shawarma plate', 'شاورما وبطاطا وسلطة وخبز', 'Shawarma, fries, salad and bread', 25, 5),
        meals('family', 'وجبة عائلية', 'Family meal', 'تكفي 4 أشخاص', 'Feeds four', 70, 5, popular: true),
      ],
    );
  }(),
  'mina-seafood': () {
    final fish = _menuOf('mina-seafood', 'fish');
    return RestaurantMenu(
      sections: [_s('fish', 'سمك وبحريات', 'Fish & seafood')],
      products: [
        fish('grilled-fish', 'سمك مشوي', 'Grilled fish', 'سمك اليوم من بحر غزة، بالكيلو', "Today's catch from Gaza's sea, per kilo", 60, 3, popular: true),
        fish('shrimp', 'جمبري بالطحينة', 'Shrimp in tahini', 'على الطريقة الغزاوية', 'Gaza style', 70, 3),
        fish('sayadieh', 'صيادية', 'Sayadieh', 'رز بالسمك والبصل المحمر', 'Fish with rice and caramelized onions', 45, 3),
      ],
    );
  }(),
  'talhawa-pizza': () {
    final pizza = _menuOf('talhawa-pizza', 'pizza');
    final pastries = _menuOf('talhawa-pizza', 'pastries');
    return RestaurantMenu(
      sections: [
        _s('pizza', 'بيتزا', 'Pizza'),
        _s('pastries', 'معجنات', 'Pastries'),
      ],
      products: [
        pizza('margherita', 'بيتزا مارجريتا', 'Margherita', 'صلصة بندورة وموزاريلا', 'Tomato sauce and mozzarella', 22, 4, options: [_pizzaSize, _pizzaExtras]),
        pizza('veggie', 'بيتزا خضار', 'Veggie pizza', 'فلفل وزيتون وفطر وبصل', 'Peppers, olives, mushrooms and onion', 25, 4, popular: true, options: [_pizzaSize, _pizzaExtras]),
        pizza('chicken', 'بيتزا دجاج', 'Chicken pizza', 'دجاج متبل مع فلفل حلو', 'Seasoned chicken with sweet peppers', 35, 4, options: [_pizzaSize, _pizzaExtras]),
        pastries('zaatar', 'مناقيش زعتر', 'Zaatar manakish', 'زعتر بلدي وزيت زيتون', 'Local thyme and olive oil', 5, 4, popular: true),
        pastries('cheese', 'فطاير جبنة', 'Cheese pies', '', '', 6, 1),
      ],
    );
  }(),
};
