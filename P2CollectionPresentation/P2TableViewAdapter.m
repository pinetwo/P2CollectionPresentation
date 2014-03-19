
#import "P2TableViewAdapter.h"
#import "P2CollectionPresentation.h"
#import "P2CollectionSection.h"
#import "P2CollectionChangeSet.h"
#import "P2ModelAwareObject.h"


#define NSNC [NSNotificationCenter defaultCenter]



@implementation P2TableViewAdapter {
    BOOL _delegateRespondsTo_reuseIdentifierForItem : 1;
    BOOL _delegateRespondsTo_configureCell : 1;
}

- (void)dealloc {
    [self _setCollectionPresentation:nil];
    [self _setTableView:nil];
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

- (void)setTableView:(UITableView *)tableView {
    [self _setTableView:tableView];
}

// KVO-safe variant for dealloc
- (void)_setTableView:(UITableView *)tableView {
    if (tableView != _tableView) {
        if (_tableView) {
            if (_tableView.dataSource == self)
                _tableView.dataSource = nil;
        }
        _tableView = tableView;
        _tableView.dataSource = self;
    }
}

- (void)setDelegate:(id<P2TableViewAdapterDelegate>)delegate {
    _delegate = delegate;
    _delegateRespondsTo_reuseIdentifierForItem = [delegate respondsToSelector:@selector(reuseIdentifierForItem:atIndexPath:inSection:ofTableViewAdapter:)];
    _delegateRespondsTo_configureCell = [delegate respondsToSelector:@selector(configureTableViewCell:forItem:atIndexPath:inSection:ofTableViewAdapter:)];
}

- (void)presentationDidChange:(NSNotification *)notification {
    [self applyChangeSet:notification.userInfo[P2CollectionPresentationChangeSetKey]];
}

- (void)applyChangeSet:(P2CollectionChangeSet *)changeSet {
    if (changeSet.fullRelolad) {
        [_tableView reloadData];
    } else {
        [_tableView beginUpdates];
        if (changeSet.indexPathsOfRemovedItems.count > 0) {
            [_tableView deleteRowsAtIndexPaths:changeSet.indexPathsOfRemovedItems withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        if (changeSet.indexesOfRemovedSections.count > 0) {
            [_tableView deleteSections:changeSet.indexesOfRemovedSections withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        if (changeSet.indexesOfInsertedSections.count > 0) {
            [_tableView insertSections:changeSet.indexesOfInsertedSections withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        [changeSet enumerateMovedItemsWithBlock:^(NSIndexPath *indexPath, NSIndexPath *newIndexPath) {
            [_tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        }];

        if (changeSet.indexPathsOfAddedItems.count > 0) {
            [_tableView insertRowsAtIndexPaths:changeSet.indexPathsOfAddedItems withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [_tableView endUpdates];
    }
}

- (void)reloadData {
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _collectionPresentation.visibleSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    P2CollectionSection *section = _collectionPresentation.visibleSections[sectionIndex];
    return section.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    P2CollectionSection *section = _collectionPresentation.visibleSections[indexPath.section];
    id item = section.items[indexPath.item];

    NSString *reuseIdentifier = nil;
    if (_delegateRespondsTo_reuseIdentifierForItem)
        reuseIdentifier = [_delegate reuseIdentifierForItem:item
                                                atIndexPath:indexPath
                                                  inSection:section
                                         ofTableViewAdapter:self];
    if (!reuseIdentifier)
        reuseIdentifier = NSStringFromClass([item class]);

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    if ([cell conformsToProtocol:@protocol(P2ModelAwareObject)]) {
        [(id<P2ModelAwareObject>)cell setRepresentedObject:item];
    }

    if (_delegateRespondsTo_configureCell) {
        [_delegate configureTableViewCell:cell
                                  forItem:item
                              atIndexPath:indexPath
                                inSection:section
                       ofTableViewAdapter:self];
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
