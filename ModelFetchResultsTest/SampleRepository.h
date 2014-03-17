
#import <Foundation/Foundation.h>

@class SampleItem;

@interface SampleRepository : NSObject

+ (instancetype)sharedRepository;

@property(nonatomic) NSArray *items;

- (IBAction)addItem:(id)sender;
- (void)removeItem:(SampleItem *)item;

- (void)randomize;

@end
