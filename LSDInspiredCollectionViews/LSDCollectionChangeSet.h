
#import <Foundation/Foundation.h>


@interface LSDCollectionChangeSet : NSObject

@property(nonatomic, getter=isFullReload) BOOL fullRelolad;
@property(nonatomic) NSDictionary *itemIndexPaths;
@property(nonatomic) NSArray *addedItems;
@property(nonatomic) NSArray *removedItems;
@property(nonatomic) NSArray *movedItems;
@property(nonatomic) NSArray *addedSections;
@property(nonatomic) NSArray *removedSections;

@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

- (void)obtainInsertedSectionsWithBlock:(void(^)(NSIndexSet *insertedSections))block;
- (void)obtainRemovedSectionsWithBlock:(void(^)(NSIndexSet *removedSections))block;
- (void)enumerateMovedSectionsWithBlock:(void(^)(NSInteger section, NSInteger newSection))block;

- (void)obtainInsertedItemsWithBlock:(void(^)(NSArray *indexPaths))block;
- (void)obtainRemovedItemsWithBlock:(void(^)(NSArray *indexPaths))block;
- (void)enumerateMovedItemsWithBlock:(void(^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath))block;

@end
