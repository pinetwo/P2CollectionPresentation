
#import <Foundation/Foundation.h>

@class DemoItem;

@interface DemoRepository : NSObject

+ (instancetype)sharedRepository;

@property(nonatomic) NSArray *items;

- (IBAction)addItem:(id)sender;
- (void)removeItem:(DemoItem *)item;

- (void)randomize;

@end
