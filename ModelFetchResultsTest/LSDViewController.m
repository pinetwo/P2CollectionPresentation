
#import "LSDViewController.h"
#import "LSDCollectionViewAdapter.h"
#import "LSDCollectionPresentation.h"
#import "LSDCollectionSection.h"
#import "LSDCell.h"
#import "SampleRepository.h"
#import "SampleItem.h"

@interface LSDViewController () <LSDCollectionViewAdapterDelegate>

@property (strong, nonatomic) IBOutlet LSDCollectionViewAdapter *adapter;

@end

@implementation LSDViewController {
    LSDCollectionPresentation *_collectionPresentation;
    NSTimer *_crashTestTimer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _collectionPresentation = [LSDCollectionPresentation new];
//    _collectionPresentation.itemSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES]];
    _collectionPresentation.sectionSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"groupingValue" ascending:YES]];

    _collectionPresentation.predefinedSections = @[
        [[LSDCollectionSection alloc] initWithDictionary:@{
            @"title": @"Cheap Items",
            @"groupingValue": @(NSIntegerMin),
            @"selectionCriteria": [NSPredicate predicateWithFormat:@"price < 1000"],
        }]
    ];
    _collectionPresentation.groupingKeyPath = @"priceScale";

    _collectionPresentation.sectionConfigurationBlock = ^(LSDCollectionSection *section) {
        section.supplementaryViewReuseIdentifiers = @{UICollectionElementKindSectionHeader: @"header"};
    };
    _collectionPresentation.dynamicSectionConfigurationBlock = ^(LSDCollectionSection *section) {
        section.title = [NSString stringWithFormat:@"%@000", section.groupingValue];
    };

    _adapter.collectionPresentation = _collectionPresentation;
    [_collectionPresentation bindToModel:[SampleRepository sharedRepository] keyPath:@"items"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addNewItem:(id)sender {
    [[SampleRepository sharedRepository] addItem:[SampleItem new]];
}

- (IBAction)randomizePrice:(id)sender {
    while (![sender isKindOfClass:LSDCell.class])
        sender = [sender superview];
    [[sender representedObject] randomizePrice];
    [_collectionPresentation reloadData];
}

- (IBAction)performCrashTest:(id)sender {
    _crashTestTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[SampleRepository sharedRepository] selector:@selector(randomize) userInfo:nil repeats:YES];
}

@end
