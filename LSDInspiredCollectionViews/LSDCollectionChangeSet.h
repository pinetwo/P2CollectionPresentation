
#import <Foundation/Foundation.h>


@interface LSDCollectionChangeSet : NSObject

@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

- (void)obtainInsertedSectionsWithBlock:(void(^)(NSIndexSet *insertedSections))block;
- (void)obtainRemovedSectionsWithBlock:(void(^)(NSIndexSet *removedSections))block;
- (void)enumerateMovedSectionsWithBlock:(void(^)(NSInteger section, NSInteger newSection))block;

- (void)obtainInsertedItemsWithBlock:(void(^)(NSIndexSet *indexSet))block;
- (void)obtainRemovedItemsWithBlock:(void(^)(NSIndexSet *indexSet))block;
- (void)enumerateMovedItemsWithBlock:(void(^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath))block;

@end
