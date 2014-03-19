
#import <UIKit/UIKit.h>
#import "P2ModelAwareObject.h"
#import "P2CollectionSection.h"

@interface SampleHeader : UICollectionReusableView <P2ModelAwareObject>

@property(nonatomic) P2CollectionSection *representedObject;

@end
