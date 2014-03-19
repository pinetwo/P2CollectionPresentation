
#import "DemoHeader.h"

@interface DemoHeader ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end


@implementation DemoHeader

- (void)setRepresentedObject:(P2CollectionSection *)representedObject {
    _representedObject = representedObject;
    _textLabel.text = representedObject.title;
}

@end
