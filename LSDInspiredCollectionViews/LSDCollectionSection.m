
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

- (NSString *)identifierOrGroupingValue {
    return (_identifier ?: _groupingValue) ?: [NSNull null];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%d %@: %@)", (int)self.visibleSectionIndex, self.identifierOrGroupingValue, self.items];
}

@end
