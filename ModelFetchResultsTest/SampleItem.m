
#import "SampleItem.h"


static NSString *RandomString(NSArray *array) {
    return array[rand() % array.count];
}


@implementation SampleItem

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *adjectives = [@"adorable burdensome cheerful decent elaborate fabulous hideous impeccable jovial kosher likable nifty organic playful quarrelsome reckless silly tedious unruly vibrant whimsical yummy zealous" componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *colors = [@"amber blueberry cerise denim emerald fuchsia ginger honeydew ivory jasmine khaki lemon mahogany neon ochre pastel raspberry scarlet tomato ultramarine vanilla waterspout xanadu zaffre" componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // TODO: pull more from http://phrontistery.info/m.html etc
        NSArray *nouns = [@"auxanometer boggart chasseur drail ekka fandango gambeson hawse ixia jabberwock kersey lorimer" componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        _title = [NSString stringWithFormat:@"%@ %@ %@", RandomString(adjectives), RandomString(colors), RandomString(nouns)];
        _price = random() % 5000;
    }
    return self;
}

- (NSInteger)priceScale {
    return floor(log10(_price));
}

+ (NSSet *)keyPathsForValuesAffectingPriceScale {
    return [NSSet setWithObject:@"price"];
}

@end
