
#import <UIKit/UIKit.h>
#import "P2ModelAwareObject.h"
#import "P2CollectionSection.h"

@interface DemoHeader : UICollectionReusableView <P2ModelAwareObject>

@property(nonatomic) P2CollectionSection *representedObject;

@end
