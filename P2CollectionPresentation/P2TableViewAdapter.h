
#import <UIKit/UIKit.h>


@class P2CollectionPresentation;
@class P2CollectionSection;

@protocol P2TableViewAdapterDelegate;


@interface P2TableViewAdapter : NSObject <UITableViewDataSource>

@property(nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) IBOutlet P2CollectionPresentation *collectionPresentation;
@property(nonatomic, weak) IBOutlet id<P2TableViewAdapterDelegate> delegate;

@end


@protocol P2TableViewAdapterDelegate <NSObject>
@optional

// defaults to the item's class name
- (NSString *)reuseIdentifierForItem:(id)item
                         atIndexPath:(NSIndexPath *)indexPath
                           inSection:(P2CollectionSection *)section
                  ofTableViewAdapter:(P2TableViewAdapter *)adapter;

// if the item conforms to P2ModelAwareCollectionViewCell, setRepresentedObject is called before this method
- (void)configureTableViewCell:(UITableViewCell *)cell
                       forItem:(id)item
                   atIndexPath:(NSIndexPath *)indexPath
                     inSection:(P2CollectionSection *)section
            ofTableViewAdapter:(P2TableViewAdapter *)adapter;

@end