
#import <Foundation/Foundation.h>
#import "P2CollectionSection.h"


extern NSString *const P2CollectionPresentationDidChangeNotification;
extern NSString *const P2CollectionPresentationChangeSetKey; // P2CollectionChangeSet


@class P2CollectionSection;


@interface P2CollectionPresentation : NSObject

// KVO helpers
- (void)bindToModel:(NSObject *)model keyPath:(NSString *)keyPath;
@property(nonatomic, readonly) id model;
@property(nonatomic, copy, readonly) NSString *keyPath;


// inputs
@property(nonatomic, copy) NSArray *objects;  // set automatically by KVO
- (void)reloadData; // call to resort, regroup and refilter existing objects

@property(nonatomic, copy) NSArray *predefinedSections;
@property(nonatomic, copy) NSArray *itemSortDescriptors;
@property(nonatomic, copy) NSArray *sectionSortDescriptors;
@property(nonatomic, copy) NSString *groupingKeyPath;
@property(nonatomic, copy) P2CollectionSectionConfigurationBlock sectionConfigurationBlock;
@property(nonatomic, copy) P2CollectionSectionConfigurationBlock dynamicSectionConfigurationBlock;

// outputs
@property(nonatomic, copy) NSArray *visibleSections;

@end
