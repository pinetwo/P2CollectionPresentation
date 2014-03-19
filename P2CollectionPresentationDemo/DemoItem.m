
#import "DemoItem.h"


static NSString *RandomString(NSArray *array) {
    return array[rand() % array.count];
}


@implementation DemoItem

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *adjectives = [@"adorable burdensome cheerful decent elaborate fabulous hideous impeccable jovial kosher likable nifty organic playful quarrelsome reckless silly tedious unruly vibrant whimsical yummy zealous" componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *colors = [@"amber blueberry cerise denim emerald fuchsia ginger honeydew ivory jasmine khaki lemon mahogany neon ochre pastel raspberry scarlet tomato ultramarine vanilla waterspout xanadu zaffre" componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        _title = [NSString stringWithFormat:@"%@ %@", RandomString(adjectives), RandomString(colors)];
        [self randomizePrice];
    }
    return self;
}

- (void)randomizePrice {
    _price = random() % 5000;
}

- (NSInteger)priceScale {
    return _price / 1000;
}

+ (NSSet *)keyPathsForValuesAffectingPriceScale {
    return [NSSet setWithObject:@"price"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%d %@)", (int)_price, _title];
}

@end
