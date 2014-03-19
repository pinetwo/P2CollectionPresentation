
#import "P2CollectionViewAdapter.h"
#import "P2CollectionPresentation.h"
#import "P2CollectionSection.h"
#import "P2CollectionChangeSet.h"
#import "P2ModelAwareObject.h"


#define NSNC [NSNotificationCenter defaultCenter]


@implementation P2CollectionViewAdapter {
    BOOL _delegateRespondsTo_reuseIdentifierForItem : 1;
    BOOL _delegateRespondsTo_configureCollectionViewCell : 1;
}

- (void)dealloc {
    [self _setCollectionPresentation:nil];
    [self _setCollectionView:nil];
}

- (void)setCollectionPresentation:(P2CollectionPresentation *)collectionPresentation {
    [self _setCollectionPresentation:collectionPresentation];
}

// KVO-safe variant for dealloc
- (void)_setCollectionPresentation:(P2CollectionPresentation *)collectionPresentation {
    if (collectionPresentation != _collectionPresentation) {
        if (_collectionPresentation) {
            [NSNC removeObserver:self
                            name:P2CollectionPresentationDidChangeNotification
                          object:_collectionPresentation];
        }

        _collectionPresentation = collectionPresentation;

        if (_collectionPresentation) {
            [NSNC addObserver:self
                     selector:@selector(presentationDidChange:)
                         name:P2CollectionPresentationDidChangeNotification
                       object:_collectionPresentation];
        }

        [self reloadData];
    }
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    [self _setCollectionView:collectionView];
}

// KVO-safe variant for dealloc
- (void)_setCollectionView:(UICollectionView *)collectionView {
    if (collectionView != _collectionView) {
        if (_collectionView) {
            if (_collectionView.dataSource == self)
                _collectionView.dataSource = nil;
        }
        _collectionView = collectionView;
        _collectionView.dataSource = self;
    }
}

- (void)setDelegate:(id<P2CollectionViewAdapterDelegate>)delegate {
    _delegate = delegate;
    _delegateRespondsTo_reuseIdentifierForItem = [delegate respondsToSelector:@selector(reuseIdentifierForItem:atIndexPath:inSection:ofCollectionViewAdapter:)];
    _delegateRespondsTo_configureCollectionViewCell = [delegate respondsToSelector:@selector(configureCollectionViewCell:forItem:atIndexPath:inSection:ofCollectionViewAdapter:)];
}

- (void)presentationDidChange:(NSNotification *)notification {
    [self applyChangeSet:notification.userInfo[P2CollectionPresentationChangeSetKey]];
}

- (void)applyChangeSet:(P2CollectionChangeSet *)changeSet {
    if (changeSet.fullRelolad) {
        [_collectionView reloadData];
    } else {
        [_collectionView performBatchUpdates:^{
            if (changeSet.indexPathsOfRemovedItems.count > 0) {
                [_collectionView deleteItemsAtIndexPaths:changeSet.indexPathsOfRemovedItems];
            }
            if (changeSet.indexesOfRemovedSections.count > 0) {
                [_collectionView deleteSections:changeSet.indexesOfRemovedSections];
            }

            if (changeSet.indexesOfInsertedSections.count > 0) {
                [_collectionView insertSections:changeSet.indexesOfInsertedSections];
            }

            [changeSet enumerateMovedItemsWithBlock:^(NSIndexPath *indexPath, NSIndexPath *newIndexPath) {
                [_collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];

            if (changeSet.indexPathsOfAddedItems.count > 0) {
                [_collectionView insertItemsAtIndexPaths:changeSet.indexPathsOfAddedItems];
            }
        } completion:^(BOOL finished) {
        }];
    }

    //- (void)insertSections:(NSIndexSet *)sections;
    //- (void)deleteSections:(NSIndexSet *)sections;
    //- (void)reloadSections:(NSIndexSet *)sections;
    //- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;
    //
    //- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths;
    //- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths;
    //- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths;
    //- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
    //
    //- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion; // allows multiple insert/delete/reload/move calls to be animated simultaneously. Nestable.
}

- (void)reloadData {
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _collectionPresentation.visibleSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    P2CollectionSection *section = _collectionPresentation.visibleSections[sectionIndex];
    return section.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    P2CollectionSection *section = _collectionPresentation.visibleSections[indexPath.section];
    id item = section.items[indexPath.item];

    NSString *reuseIdentifier = nil;
    if (_delegateRespondsTo_reuseIdentifierForItem)
        reuseIdentifier = [_delegate reuseIdentifierForItem:item
                                                atIndexPath:indexPath
                                                  inSection:section
                                    ofCollectionViewAdapter:self];
    if (!reuseIdentifier)
        reuseIdentifier = NSStringFromClass([item class]);

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    if ([cell conformsToProtocol:@protocol(P2ModelAwareObject)]) {
        [(id<P2ModelAwareObject>)cell setRepresentedObject:item];
    }

    if (_delegateRespondsTo_configureCollectionViewCell) {
        [_delegate configureCollectionViewCell:cell
                                       forItem:item
                                   atIndexPath:indexPath
                                     inSection:section
                       ofCollectionViewAdapter:self];
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    P2CollectionSection *section = _collectionPresentation.visibleSections[indexPath.section];
    NSString *reuseIdentifier = section.supplementaryViewReuseIdentifiers[kind];
    if (reuseIdentifier) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        if ([view conformsToProtocol:@protocol(P2ModelAwareObject)]) {
            [(id<P2ModelAwareObject>)view setRepresentedObject:section];
        }
        return view;
    } else {
        return nil;
    }
}

@end
