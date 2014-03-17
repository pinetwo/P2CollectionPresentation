
#import "LSDCollectionViewAdapter.h"
#import "LSDCollectionPresentation.h"
#import "LSDCollectionSection.h"
#import "LSDCollectionChangeSet.h"
#import "LSDModelAwareCollectionViewCell.h"


#define NSNC [NSNotificationCenter defaultCenter]


@implementation LSDCollectionViewAdapter {
    BOOL _delegateRespondsTo_reuseIdentifierForItem : 1;
    BOOL _delegateRespondsTo_configureCollectionViewCell : 1;
}

- (void)dealloc {
    [self _setCollectionPresentation:nil];
    [self _setCollectionView:nil];
}

- (void)setCollectionPresentation:(LSDCollectionPresentation *)collectionPresentation {
    [self _setCollectionPresentation:collectionPresentation];
}

// KVO-safe variant for dealloc
- (void)_setCollectionPresentation:(LSDCollectionPresentation *)collectionPresentation {
    if (collectionPresentation != _collectionPresentation) {
        if (_collectionPresentation) {
            [NSNC removeObserver:self
                            name:LSDCollectionPresentationDidChangeNotification
                          object:_collectionPresentation];
        }

        _collectionPresentation = collectionPresentation;

        if (_collectionPresentation) {
            [NSNC addObserver:self
                     selector:@selector(presentationDidChange:)
                         name:LSDCollectionPresentationDidChangeNotification
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

- (void)setDelegate:(id<LSDCollectionViewAdapterDelegate>)delegate {
    _delegate = delegate;
    _delegateRespondsTo_reuseIdentifierForItem = [delegate respondsToSelector:@selector(reuseIdentifierForItem:atIndexPath:inSection:ofCollectionViewAdapter:)];
    _delegateRespondsTo_configureCollectionViewCell = [delegate respondsToSelector:@selector(configureCollectionViewCell:forItem:atIndexPath:inSection:ofCollectionViewAdapter:)];
}

- (void)presentationDidChange:(NSNotification *)notification {
    [self applyChangeSet:notification.userInfo[LSDCollectionPresentationChangeSetKey]];
}

- (void)applyChangeSet:(LSDCollectionChangeSet *)changeSet {
    // TODO
    [_collectionView reloadData];

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
    LSDCollectionSection *section = _collectionPresentation.visibleSections[sectionIndex];
    return section.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSDCollectionSection *section = _collectionPresentation.visibleSections[indexPath.section];
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

    if ([cell conformsToProtocol:@protocol(LSDModelAwareCollectionViewCell)]) {
        [(id<LSDModelAwareCollectionViewCell>)cell setRepresentedObject:item];
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

@end
