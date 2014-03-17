
#import "LSDCell.h"
#import "SampleItem.h"
#import "SampleRepository.h"


@interface LSDCell ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation LSDCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor redColor];
    self.layer.borderColor = [UIColor blueColor].CGColor;
    self.layer.borderWidth = 1.0;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    SampleItem *item = representedObject;
    _textLabel.text = [NSString stringWithFormat:@"%@ %@", item.title, @(item.price)];
}

- (IBAction)delete:(id)sender {
    [[SampleRepository sharedRepository] removeItem:self.representedObject];
}

@end
