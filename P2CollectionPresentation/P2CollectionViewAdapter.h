
#import <UIKit/UIKit.h>


@class P2CollectionPresentation;
@class P2CollectionSection;

@protocol P2CollectionViewAdapterDelegate;


@interface P2CollectionViewAdapter : NSObject <UICollectionViewDataSource>

@property(nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic) IBOutlet P2CollectionPresentation *collectionPresentation;
@property(nonatomic, weak) IBOutlet id<P2CollectionViewAdapterDelegate> delegate;

@end


@protocol P2CollectionViewAdapterDelegate <NSObject>
@optional

// defaults to the item's class name
- (NSString *)reuseIdentifierForItem:(id)item
                         atIndexPath:(NSIndexPath *)indexPath
                           inSection:(P2CollectionSection *)section
             ofCollectionViewAdapter:(P2CollectionViewAdapter *)adapter;

// if the item conforms to P2ModelAwareCollectionViewCell, setRepresentedObject is called before this method
- (void)configureCollectionViewCell:(UICollectionViewCell *)cell
                            forItem:(id)item
                        atIndexPath:(NSIndexPath *)indexPath
                          inSection:(P2CollectionSection *)section
            ofCollectionViewAdapter:(P2CollectionViewAdapter *)adapter;

//
//- collectionView:(UICollectionView *)collectionView cellForItem:(id)item inSection:(P2CollectionSection *)section atIndexPath:(NSIndexPath *)indexPath {
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItem:(id)item inSection:(P2CollectionSection *)section atIndexPath:(NSIndexPath *)indexPath {
//
//}

@end