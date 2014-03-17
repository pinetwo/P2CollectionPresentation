
#import "LSDCollectionSection.h"

@implementation LSDCollectionSection

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _userData = [dictionary copy];

        _title = dictionary[@"title"];
        _selectionCriteria = dictionary[@"selectionCriteria"];
        _groupingValue = dictionary[@"groupingValue"];
    }
    return self;
}

@end
