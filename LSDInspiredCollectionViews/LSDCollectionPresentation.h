
#import <Foundation/Foundation.h>
#import "LSDCollectionSection.h"


extern NSString *const LSDCollectionPresentationDidChangeNotification;
extern NSString *const LSDCollectionPresentationChangeSetKey; // LSDCollectionChangeSet


@class LSDCollectionSection;


@interface LSDCollectionPresentation : NSObject

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
@property(nonatomic, copy) LSDCollectionSectionConfigurationBlock sectionConfigurationBlock;
@property(nonatomic, copy) LSDCollectionSectionConfigurationBlock dynamicSectionConfigurationBlock;

// outputs
@property(nonatomic, copy) NSArray *visibleSections;

@end
