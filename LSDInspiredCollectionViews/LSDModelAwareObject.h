
#import <UIKit/UIKit.h>


@protocol LSDModelAwareObject <NSObject>

- (void)setRepresentedObject:(id)object;

@end


@interface LSDModelAwareCollectionViewCell : UICollectionViewCell <LSDModelAwareObject>

@property(nonatomic) id representedObject;

@end
