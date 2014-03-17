
#import <UIKit/UIKit.h>


@class LSDCollectionPresentation;
@class LSDCollectionSection;

@protocol LSDCollectionViewAdapterDelegate;


@interface LSDCollectionViewAdapter : NSObject <UICollectionViewDataSource>

@property(nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic) IBOutlet LSDCollectionPresentation *collectionPresentation;
@property(nonatomic, weak) IBOutlet id<LSDCollectionViewAdapterDelegate> delegate;

@end


@protocol LSDCollectionViewAdapterDelegate <NSObject>
@optional

// defaults to the item's class name
- (NSString *)reuseIdentifierForItem:(id)item
                         atIndexPath:(NSIndexPath *)indexPath
                           inSection:(LSDCollectionSection *)section
             ofCollectionViewAdapter:(LSDCollectionViewAdapter *)adapter;

// if the item conforms to LSDModelAwareCollectionViewCell, setRepresentedObject is called before this method
- (void)configureCollectionViewCell:(UICollectionViewCell *)cell
                            forItem:(id)item
                        atIndexPath:(NSIndexPath *)indexPath
                          inSection:(LSDCollectionSection *)section
            ofCollectionViewAdapter:(LSDCollectionViewAdapter *)adapter;

//
//- collectionView:(UICollectionView *)collectionView cellForItem:(id)item inSection:(LSDCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath {
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItem:(id)item inSection:(LSDCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath {
//
//}

@end