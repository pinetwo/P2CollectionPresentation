
#import <UIKit/UIKit.h>


@protocol LSDModelAwareCollectionViewCell <NSObject>

- (void)setRepresentedObject:(id)object;

@end


@interface LSDModelAwareCollectionViewCell : UICollectionViewCell <LSDModelAwareCollectionViewCell>

@property(nonatomic) id representedObject;

@end
