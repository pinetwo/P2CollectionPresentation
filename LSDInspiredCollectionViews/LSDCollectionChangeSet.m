
#import "LSDCollectionChangeSet.h"

@implementation LSDCollectionChangeSet

- (void)obtainInsertedItemsWithBlock:(void(^)(NSArray *indexPaths))block {
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSArray *item in _addedItems) {
        NSIndexPath *indexPath = _itemIndexPaths[[NSValue valueWithNonretainedObject:item]];
        NSAssert(!!indexPath, @"Internal error, added item does not have an index path");
        [indexPaths addObject:indexPath];
    }
    if (indexPaths.count > 0)
        block(indexPaths);
}

@end
