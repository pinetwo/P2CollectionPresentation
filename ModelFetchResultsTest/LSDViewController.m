
#import "LSDViewController.h"
#import "LSDCollectionViewAdapter.h"
#import "LSDCollectionPresentation.h"
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
    [_collectionPresentation bindToModel:[SampleRepository sharedRepository] keyPath:@"items"];
    _adapter.collectionPresentation = _collectionPresentation;
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
