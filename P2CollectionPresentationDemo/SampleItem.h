
#import <Foundation/Foundation.h>

@interface SampleItem : NSObject

@property(nonatomic) NSString *title;
@property(nonatomic) NSInteger price;
@property(nonatomic, readonly) NSInteger priceScale;

- (void)randomizePrice;

@end
