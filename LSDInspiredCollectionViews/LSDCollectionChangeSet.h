
#import <Foundation/Foundation.h>


@interface LSDCollectionChangeSet : NSObject

@property(nonatomic, getter=isFullReload) BOOL fullRelolad;
@property(nonatomic) NSDictionary *itemIndexPaths;
@property(nonatomic) NSArray *addedItems;
@property(nonatomic) NSArray *indexPathsOfRemovedItems;
@property(nonatomic) NSArray *movedItems;
@property(nonatomic) NSIndexSet *indexesOfRemovedSections;
@property(nonatomic) NSIndexSet *indexesOfInsertedSections;

@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

- (void)enumerateMovedSectionsWithBlock:(void(^)(NSInteger section, NSInteger newSection))block;

- (void)obtainInsertedItemsWithBlock:(void(^)(NSArray *indexPaths))block;
- (void)enumerateMovedItemsWithBlock:(void(^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath))block;

@end
