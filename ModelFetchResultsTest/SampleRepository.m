
#import "SampleRepository.h"
#import "SampleItem.h"

@implementation SampleRepository {
    NSMutableArray *_items;
}

+ (instancetype)sharedRepository {
    static SampleRepository *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SampleRepository new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        [self addItem:nil];
        [self addItem:nil];
        [self addItem:nil];
    }
    return self;
}

- (IBAction)addItem:(id)sender {
    [self willChangeValueForKey:@"items"];
    [_items addObject:[SampleItem new]];
    [self didChangeValueForKey:@"items"];
}

- (void)removeItem:(SampleItem *)item {
    [self willChangeValueForKey:@"items"];
    [_items removeObject:item];
    [self didChangeValueForKey:@"items"];
}

@end
