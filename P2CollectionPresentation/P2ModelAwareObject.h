
#import <UIKit/UIKit.h>


@protocol P2ModelAwareObject <NSObject>

- (void)setRepresentedObject:(id)object;

@end


@interface P2ModelAwareCollectionViewCell : UICollectionViewCell <P2ModelAwareObject>

@property(nonatomic) id representedObject;

@end
