
#import "LSDViewController.h"
#import "LSDCollectionViewAdapter.h"
#import "LSDCollectionPresentation.h"
#import "LSDCollectionSection.h"
#import "SampleRepository.h"
#import "SampleItem.h"

@interface LSDViewController () <LSDCollectionViewAdapterDelegate>

@property (strong, nonatomic) IBOutlet LSDCollectionViewAdapter *adapter;

@end

@implementation LSDViewController {
    LSDCollectionPresentation *_collectionPresentation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _collectionPresentation = [LSDCollectionPresentation new];
    _adapter.collectionPresentation = _collectionPresentation;

    _collectionPresentation.predefinedSections = @[
        [[LSDCollectionSection alloc] initWithDictionary:@{
            @"title": @"Cheap Items",
            @"selectionCriteria": [NSPredicate predicateWithFormat:@"price < 1000"],
        }]
    ];

    _collectionPresentation.sectionConfigurationBlock = ^(LSDCollectionSection *section) {
        section.supplementaryViewReuseIdentifiers = @{UICollectionElementKindSectionHeader: @"header"};
    };
    _collectionPresentation.dynamicSectionConfigurationBlock = ^(LSDCollectionSection *section) {
        section.title = @"Others";
    };

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

@end
