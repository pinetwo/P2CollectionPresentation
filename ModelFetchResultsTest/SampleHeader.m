
#import "SampleHeader.h"

@interface SampleHeader ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end


@implementation SampleHeader

- (void)setRepresentedObject:(LSDCollectionSection *)representedObject {
    _representedObject = representedObject;
    _textLabel.text = representedObject.title;
}

@end
