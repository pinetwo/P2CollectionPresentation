
#import "LSDCollectionChangeSet.h"

@implementation LSDCollectionChangeSet

- (void)enumerateMovedItemsWithBlock:(void(^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath))block {
    for (NSArray *pair in _movedItems) {
        block(pair[0], pair[1]);
    }
}

- (NSIndexPath *)adjustOldIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;

    if ([_indexesOfRemovedSections containsIndex:section]) {
        return nil;
    }

    if (section > 0) {
        section -= [_indexesOfRemovedSections countOfIndexesInRange:NSMakeRange(0, section)];
    }
    section += [_indexesOfInsertedSections countOfIndexesInRange:NSMakeRange(0, section + 1)];

    for (NSIndexPath *indexPath in _indexPathsOfRemovedItems) {
        if (indexPath.section == section) {
            if (indexPath.item <= item) {
                --item;
            }
        }
    }

    for (NSArray *pair in _movedItems) {
        NSIndexPath *oldIndexPath = pair[0];
        NSIndexPath *newIndexPath = pair[1];
        if (oldIndexPath.section == section)
            if (oldIndexPath.item < item) {
                --item;
            }
        if (newIndexPath.section == section)
            if (newIndexPath.item <= item) {
                ++item;
            }
    }

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSIndexPath *)adjustNewIndexPathBeforeItemAdditions:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;

    for (NSIndexPath *indexPath in _indexPathsOfAddedItems) {
        if (indexPath.section == section) {
            if (indexPath.item <= item) {
                --item;
            }
        }
    }

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSString *)description {
    return [@{@"added sections": _indexesOfInsertedSections,
              @"removed sections": _indexesOfRemovedSections,
              @"added items": _indexPathsOfAddedItems,
              @"removed items": _indexPathsOfRemovedItems,
              @"moved items": _movedItems} description];
}

@end
