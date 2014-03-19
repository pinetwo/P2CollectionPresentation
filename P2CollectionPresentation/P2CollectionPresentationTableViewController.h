
#import <UIKit/UIKit.h>
#import "P2TableViewAdapter.h"
#import "P2CollectionPresentation.h"


@interface P2CollectionPresentationTableViewController : UITableViewController <P2TableViewAdapterDelegate>

@property(nonatomic) IBOutlet P2TableViewAdapter *tableViewAdapter;
@property(nonatomic) IBOutlet P2CollectionPresentation *collectionPresentation;

@end
