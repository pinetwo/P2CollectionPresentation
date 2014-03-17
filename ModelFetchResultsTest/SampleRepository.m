
#import "SampleRepository.h"
#import "SampleItem.h"

static void *SampleRepositoryItemDidChange = "SampleRepositoryItemDidChange";

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

- (void)randomize {
    if (YES || rand() % 2 == 0) {
        int sel = rand() % 3;
        if (sel == 0 && _items.count >= 2) {
            NSInteger oldIndex = rand() % _items.count;
            [self willChangeValueForKey:@"items"];
            id item = _items[oldIndex];
            [_items removeObject:item];

            NSInteger newIndex = rand() % _items.count;
            [_items insertObject:item atIndex:newIndex];
            [self didChangeValueForKey:@"items"];
        } else if (sel == 1 && _items.count >= 1) {
            NSInteger oldIndex = rand() % _items.count;
            [self removeItem:_items[oldIndex]];
        } else {
            [self addItem:nil];
        }
    }
}

@end
