
#import <Foundation/Foundation.h>


@class LSDCollectionSection;


typedef void (^LSDCollectionSectionConfigurationBlock)(LSDCollectionSection *section);


@interface LSDCollectionSection : NSObject

// inputs (filled in by the client of LSDCollectionPresentation)
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSDictionary *userData;

// Set this for predefined sections to explicitly specify the selection criteria.
// Can also set `groupingValue` key to select objects by the value of `groupingKeyPath`.
@property(nonatomic, copy) NSPredicate *selectionCriteria;

// Index of a visible section after sorting and filtering, filled in by LSDCollectionPresentation.
// NSIntegerMin for invisible sections.
@property(nonatomic) NSInteger sectionIndex;

// Visible items of a visible section after sorting and filtering, filled in by LSDCollectionPresentation.
// Empty array for invisible sections.
@property(nonatomic, copy) NSArray *items;

// Value of groupingKeyPath common for the dynamic section's items.
//
// For dynamic sections, this is filled in by LSDCollectionPresentation.
// For predefined sections, this can be provided by the client and is nil otherwise.
@property(nonatomic) id groupingValue;

// An ordinal value which can be useful as a sections sort key.
//
// For dynamic sections, this is set by LSDCollectionPresentation, from zero to the number of dynamic sections
// minus one.
//
// For predefined sections, this defaults to NSIntegerMin and can be set by the client to affect the ordering
// of predefined sections relative to the dynamic sections.
@property(nonatomic) NSInteger ordinal;

@end
