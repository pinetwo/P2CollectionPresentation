
#import "P2CollectionPresentationTableViewController.h"

@interface P2CollectionPresentationTableViewController ()

@end

@implementation P2CollectionPresentationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_collectionPresentation) {
        _collectionPresentation = [P2CollectionPresentation new];
    }
    if (!_tableViewAdapter) {
        _tableViewAdapter = [P2TableViewAdapter new];
        _tableViewAdapter.delegate = self;
        _tableViewAdapter.tableView = self.tableView;
        self.tableView.dataSource = _tableViewAdapter;
        _tableViewAdapter.collectionPresentation = _collectionPresentation;
    }
}

@end
