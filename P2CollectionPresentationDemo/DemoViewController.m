
#import "DemoViewController.h"
#import "P2CollectionViewAdapter.h"
#import "P2CollectionPresentation.h"
#import "P2CollectionSection.h"
#import "DemoCell.h"
#import "DemoRepository.h"
#import "DemoItem.h"

@interface DemoViewController () <P2CollectionViewAdapterDelegate>

@property (strong, nonatomic) IBOutlet P2CollectionViewAdapter *adapter;

@end

@implementation DemoViewController {
    P2CollectionPresentation *_collectionPresentation;
    NSTimer *_crashTestTimer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _collectionPresentation = [P2CollectionPresentation new];
//    _collectionPresentation.itemSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES]];
    _collectionPresentation.sectionSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"groupingValue" ascending:YES]];

    _collectionPresentation.predefinedSections = @[
        [[P2CollectionSection alloc] initWithDictionary:@{
            @"title": @"Cheap Items",
            @"groupingValue": @(NSIntegerMin),
            @"selectionCriteria": [NSPredicate predicateWithFormat:@"price < 1000"],
        }]
    ];
    _collectionPresentation.groupingKeyPath = @"priceScale";

    _collectionPresentation.sectionConfigurationBlock = ^(P2CollectionSection *section) {
        section.supplementaryViewReuseIdentifiers = @{UICollectionElementKindSectionHeader: @"header"};
    };
    _collectionPresentation.dynamicSectionConfigurationBlock = ^(P2CollectionSection *section) {
        section.title = [NSString stringWithFormat:@"%@000", section.groupingValue];
    };

    _adapter.collectionPresentation = _collectionPresentation;
    [_collectionPresentation bindToModel:[DemoRepository sharedRepository] keyPath:@"items"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addNewItem:(id)sender {
    [[DemoRepository sharedRepository] addItem:[DemoItem new]];
}

- (IBAction)randomizePrice:(id)sender {
    while (![sender isKindOfClass:DemoCell.class])
        sender = [sender superview];
    [[sender representedObject] randomizePrice];
    [_collectionPresentation reloadData];
}

- (IBAction)performCrashTest:(id)sender {
    _crashTestTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[DemoRepository sharedRepository] selector:@selector(randomize) userInfo:nil repeats:YES];
}

@end
