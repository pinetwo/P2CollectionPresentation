
#import <Foundation/Foundation.h>


@interface LSDCollectionChangeSet : NSObject

@property(nonatomic, getter=isFullReload) BOOL fullRelolad;
@property(nonatomic) NSDictionary *itemIndexPaths;
@property(nonatomic) NSArray *indexPathsOfAddedItems;
@property(nonatomic) NSArray *indexPathsOfRemovedItems;
@property(nonatomic) NSArray *movedItems;
@property(nonatomic) NSIndexSet *indexesOfRemovedSections;
@property(nonatomic) NSIndexSet *indexesOfInsertedSections;

@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

- (void)enumerateMovedSectionsWithBlock:(void(^)(NSInteger section, NSInteger newSection))block;
- (void)enumerateMovedItemsWithBlock:(void(^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath))block;

- (NSIndexPath *)adjustOldIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)adjustNewIndexPathBeforeItemAdditions:(NSIndexPath *)indexPath;

@end
