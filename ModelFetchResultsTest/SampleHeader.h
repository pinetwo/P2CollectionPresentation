
#import <UIKit/UIKit.h>
#import "LSDModelAwareObject.h"
#import "LSDCollectionSection.h"

@interface SampleHeader : UICollectionReusableView <LSDModelAwareObject>

@property(nonatomic) LSDCollectionSection *representedObject;

@end
