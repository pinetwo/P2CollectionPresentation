
#import "LSDCollectionPresentation.h"
#import "LSDCollectionSection.h"
#import "LSDCollectionChangeSet.h"


NSString *const LSDCollectionPresentationDidChangeNotification = @"LSDCollectionPresentationDidChange";
NSString *const LSDCollectionPresentationChangeSetKey = @"changeset";


@implementation LSDCollectionPresentation {
    NSDictionary *_visibleSectionsByGroupingValue;
}

- (void)dealloc {
    [self bindToModel:nil keyPath:nil];
}


#pragma mark - Observation Helpers

- (void)bindToModel:(NSObject *)model keyPath:(NSString *)keyPath {
    if (_model && _keyPath) {
        [_model removeObserver:self forKeyPath:_keyPath];
    }

    _model = model;
    _keyPath = keyPath;

    if (_model && _keyPath) {
        [_model addObserver:self forKeyPath:_keyPath options:0 context:NULL];
    }

    [self _updateObjectsFromModel];
}

- (void)_updateObjectsFromModel {
    id objects = [_model valueForKeyPath:_keyPath];
    if (![objects isKindOfClass:NSArray.class])
        objects = [objects allObjects];
    self.objects = objects;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self _updateObjectsFromModel];
}


#pragma mark - Inputs

- (void)setPredefinedSections:(NSArray *)predefinedSections {
    [predefinedSections enumerateObjectsUsingBlock:^(LSDCollectionSection *section, NSUInteger idx, BOOL *stop) {
        if (!section.identifier) {
            section.identifier = [NSString stringWithFormat:@"predefined-%d", (int)idx];
        }
    }];

    _predefinedSections = [predefinedSections copy];
}


#pragma mark - The core :-)

- (void)setObjects:(NSArray *)objects {
    _objects = [objects copy];
    [self reloadData];
}

- (void)reloadData {
    NSArray *oldVisibleSections = _visibleSections;
    NSDictionary *oldLookupCache = [self lookupCacheForItemsInSections:oldVisibleSections];
    NSDictionary *oldSectionsByIdentifierOrGroupingValue = [self indexSectionsByIdentifierOrGroupingValue:oldVisibleSections];
    NSDictionary *oldItemsBySection = [self itemsGroupedBySectionInSections:oldVisibleSections];

    _visibleSections = [self visibleSectionsForObjects:_objects];
    _visibleSectionsByGroupingValue = [self indexSectionsByGroupingValue:_visibleSections];

    NSLog(@"New visibleSections = %@", _visibleSections);

    LSDCollectionChangeSet *changeset = [[LSDCollectionChangeSet alloc] init];
    if (oldVisibleSections) {
        NSDictionary *newLookupCache = [self lookupCacheForItemsInSections:_visibleSections];
        NSDictionary *newSectionsByIdentifierOrGroupingValue = [self indexSectionsByIdentifierOrGroupingValue:_visibleSections];

        NSMutableArray *indexPathsOfAddedItems = [NSMutableArray new];
        NSMutableArray *existingItems = [NSMutableArray new];
        NSMutableArray *indexPathsOfRemovedItems = [NSMutableArray new];
        NSMutableIndexSet *indexesOfAddedSections = [NSMutableIndexSet new];
        NSMutableIndexSet *indexesOfRemovedSections = [NSMutableIndexSet new];

        [_visibleSections enumerateObjectsUsingBlock:^(LSDCollectionSection *section, NSUInteger sectionIndex, BOOL *stop) {
            if (!oldSectionsByIdentifierOrGroupingValue[section.identifierOrGroupingValue]) {
                [indexesOfAddedSections addIndex:sectionIndex];

                [section.items enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *oldIndexPath = [self indexPathForItem:item usingLookupCache:oldLookupCache];
                    if (oldIndexPath) {
                        [existingItems addObject:item];
                    }
                }];
            } else {
                [section.items enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *oldIndexPath = [self indexPathForItem:item usingLookupCache:oldLookupCache];
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:idx inSection:section.visibleSectionIndex];
                    if (oldIndexPath) {
                        [existingItems addObject:item];
                    } else {
                        [indexPathsOfAddedItems addObject:newIndexPath];
                    }
                }];
            }
        }];

        [oldVisibleSections enumerateObjectsUsingBlock:^(LSDCollectionSection *section, NSUInteger oldSectionIndex, BOOL *stop) {
            if (!newSectionsByIdentifierOrGroupingValue[section.identifierOrGroupingValue]) {
                [indexesOfRemovedSections addIndex:oldSectionIndex];
                return;
            }

            [oldItemsBySection[section.identifierOrGroupingValue] enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [self indexPathForItem:item usingLookupCache:newLookupCache];
                if (!newIndexPath) {
                    NSIndexPath *oldIndexPath = [self indexPathForItem:item usingLookupCache:oldLookupCache];
                    [indexPathsOfRemovedItems addObject:oldIndexPath];
                }
            }];
        }];

        changeset.itemIndexPaths = newLookupCache;
        changeset.indexPathsOfAddedItems = [indexPathsOfAddedItems sortedArrayUsingSelector:@selector(compare:)];
        changeset.indexesOfInsertedSections = [indexesOfAddedSections copy];
        changeset.indexesOfRemovedSections = [indexesOfRemovedSections copy];
        changeset.indexPathsOfRemovedItems = [[[indexPathsOfRemovedItems sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];

        NSMutableArray *movedItems = [NSMutableArray new];
        changeset.movedItems = movedItems;

        for (id item in existingItems) {
            NSIndexPath *oldIndexPath = [self indexPathForItem:item usingLookupCache:oldLookupCache];
            NSIndexPath *newIndexPath = [self indexPathForItem:item usingLookupCache:newLookupCache];

            NSIndexPath *oldAdjustedIndexPath = [changeset adjustOldIndexPath:oldIndexPath];
            NSIndexPath *newAdjustedIndexPath = [changeset adjustNewIndexPathBeforeItemAdditions:newIndexPath];
            NSLog(@"Iteration 1: item %@, oldIndexPath = %@, newIndexPath = %@, oldAdjustedIndexPath = %@, newAdjustedIndexPath = %@", item, oldIndexPath, newIndexPath, oldAdjustedIndexPath, newAdjustedIndexPath);

            if ([indexesOfAddedSections containsIndex:newIndexPath.section]) {
                if (oldAdjustedIndexPath != nil) {
                    [indexPathsOfRemovedItems addObject:oldIndexPath];
                    changeset.indexPathsOfRemovedItems = [[[indexPathsOfRemovedItems sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
                }
                continue;
            }

            if (oldAdjustedIndexPath == nil) {
                [indexPathsOfAddedItems addObject:newIndexPath];
                changeset.indexPathsOfAddedItems = [indexPathsOfAddedItems sortedArrayUsingSelector:@selector(compare:)];
            } else {
                if (oldAdjustedIndexPath.section != newAdjustedIndexPath.section) {
                    [movedItems addObject:@[oldAdjustedIndexPath, newAdjustedIndexPath]];
                    changeset.movedItems = movedItems;
                }
            }
        }

        for (id item in existingItems) {
            NSIndexPath *oldIndexPath = [self indexPathForItem:item usingLookupCache:oldLookupCache];
            NSIndexPath *newIndexPath = [self indexPathForItem:item usingLookupCache:newLookupCache];

            NSIndexPath *oldAdjustedIndexPath = [changeset adjustOldIndexPath:oldIndexPath];
            NSIndexPath *newAdjustedIndexPath = [changeset adjustNewIndexPathBeforeItemAdditions:newIndexPath];

            NSLog(@"Iteration 2: item %@, oldIndexPath = %@, newIndexPath = %@, oldAdjustedIndexPath = %@, newAdjustedIndexPath = %@", item, oldIndexPath, newIndexPath, oldAdjustedIndexPath, newAdjustedIndexPath);
            if (oldAdjustedIndexPath != nil) {
                if (oldAdjustedIndexPath.section == newAdjustedIndexPath.section && oldAdjustedIndexPath.item != newAdjustedIndexPath.item) {
                    [movedItems addObject:@[oldAdjustedIndexPath, newAdjustedIndexPath]];
                    changeset.movedItems = movedItems;
                }
            }
        }

        NSLog(@"changeSet = %@", changeset);
    } else {
        changeset.fullRelolad = YES;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:LSDCollectionPresentationDidChangeNotification
                                                        object:self
                                                      userInfo:@{LSDCollectionPresentationChangeSetKey: changeset}];
}

- (NSArray *)visibleSectionsForObjects:(NSArray *)objects {
    NSMutableArray *visibleSections = [NSMutableArray new];
    NSArray *remainingObjects = _objects;

    if (_itemSortDescriptors.count > 0) {
        remainingObjects = [remainingObjects sortedArrayUsingDescriptors:_itemSortDescriptors];
    }

    for (LSDCollectionSection *section in _predefinedSections) {
        NSArray *selectedItems;
        if (section.selectionCriteria) {
            selectedItems = [remainingObjects filteredArrayUsingPredicate:section.selectionCriteria];
        } else if (section.groupingValue) {
            NSAssert(!!self.groupingKeyPath, @"groupingKeyPath must be set if predefined sections use groupingValue");
            id expectedValue = section.groupingValue;
            NSString *keyPath = self.groupingKeyPath;
            selectedItems = [remainingObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                id value = [evaluatedObject valueForKeyPath:keyPath];
                return ([value isEqual:expectedValue]);
            }]];
        } else {
            selectedItems = remainingObjects;
        }

        section.items = selectedItems;
        remainingObjects = [remainingObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ![selectedItems containsObject:evaluatedObject];
        }]];

        if (_sectionConfigurationBlock) {
            _sectionConfigurationBlock(section);
        }

        if (section.items.count > 0) {
            [visibleSections addObject:section];
        } else {
            section.visibleSectionIndex = NSIntegerMin;
        }
    }

    if (remainingObjects.count > 0) {
        if (_groupingKeyPath) {
            NSMutableDictionary *groupedItems = [NSMutableDictionary new];
            NSMutableArray *groupingValues = [NSMutableArray new];
            for (id item in remainingObjects) {
                id key = [item valueForKeyPath:_groupingKeyPath];
                if (key == nil)
                    continue;

                NSMutableArray *array = groupedItems[key];
                if (!array) {
                    array = [NSMutableArray new];
                    groupedItems[key] = array;
                    [groupingValues addObject:key];
                }
                [array addObject:item];
            }

            for (id groupingValue in groupingValues) {
                LSDCollectionSection *section = [self newSectionForGroupingValue:groupingValue];
                section.items = groupedItems[groupingValue];
                if (_dynamicSectionConfigurationBlock) {
                    _dynamicSectionConfigurationBlock(section);
                }
                if (_sectionConfigurationBlock) {
                    _sectionConfigurationBlock(section);
                }
                [visibleSections addObject:section];
            }
        } else {
            LSDCollectionSection *section = [self newSectionForGroupingValue:nil];
            section.items = remainingObjects;
            if (_dynamicSectionConfigurationBlock) {
                _dynamicSectionConfigurationBlock(section);
            }
            if (_sectionConfigurationBlock) {
                _sectionConfigurationBlock(section);
            }
            [visibleSections addObject:section];
        }
    }

    if (_sectionSortDescriptors.count > 0) {
        [visibleSections sortUsingDescriptors:_sectionSortDescriptors];
    }

    [visibleSections enumerateObjectsUsingBlock:^(LSDCollectionSection *section, NSUInteger idx, BOOL *stop) {
        section.visibleSectionIndex = idx;
    }];

    return [visibleSections copy];
}

- (LSDCollectionSection *)newSectionForGroupingValue:(id)groupingValue {
    LSDCollectionSection *section = _visibleSectionsByGroupingValue[groupingValue ?: [NSNull null]];
    if (!section) {
        section = [LSDCollectionSection new];
        section.groupingValue = groupingValue;
    }
    return section;
}

- (NSDictionary *)lookupCacheForItemsInSections:(NSArray *)sections {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [sections enumerateObjectsUsingBlock:^(LSDCollectionSection *section, NSUInteger sectionIndex, BOOL *stop) {
        [section.items enumerateObjectsUsingBlock:^(id item, NSUInteger itemIndex, BOOL *stop) {
            result[[NSValue valueWithNonretainedObject:item]] = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
        }];
    }];
    return result;
}

- (NSIndexPath *)indexPathForItem:(id)item usingLookupCache:(NSDictionary *)lookupCache {
    return lookupCache[[NSValue valueWithNonretainedObject:item]];
}

- (NSDictionary *)indexSectionsByGroupingValue:(NSArray *)sections {
    NSMutableDictionary *grouped = [NSMutableDictionary dictionary];
    for (LSDCollectionSection *section in sections) {
        if (section.identifier)
            continue;
        id key = section.groupingValue;
        if (key == nil)
            key = [NSNull null];
        grouped[key] = section;
    }
    return grouped;
}

- (NSDictionary *)indexSectionsByIdentifierOrGroupingValue:(NSArray *)sections {
    NSMutableDictionary *grouped = [NSMutableDictionary dictionary];
    for (LSDCollectionSection *section in sections) {
        id key = section.identifierOrGroupingValue;
        grouped[key] = section;
    }
    return grouped;
}

- (NSDictionary *)itemsGroupedBySectionInSections:(NSArray *)sections {
    NSMutableDictionary *grouped = [NSMutableDictionary dictionary];
    for (LSDCollectionSection *section in sections) {
        id key = section.identifierOrGroupingValue;
        grouped[key] = section.items;
    }
    return grouped;
}

#pragma mark - Outputs

@end
