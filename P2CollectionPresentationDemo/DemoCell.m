
#import "DemoCell.h"
#import "DemoItem.h"
#import "DemoRepository.h"


@interface DemoCell ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation DemoCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor redColor];
    self.layer.borderColor = [UIColor blueColor].CGColor;
    self.layer.borderWidth = 1.0;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    DemoItem *item = representedObject;
    _textLabel.text = [NSString stringWithFormat:@"%@ %@", item.title, @(item.price)];
}

- (IBAction)delete:(id)sender {
    [[DemoRepository sharedRepository] removeItem:self.representedObject];
}

@end
