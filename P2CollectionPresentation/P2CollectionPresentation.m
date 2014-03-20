
#import "P2CollectionPresentation.h"
#import "P2CollectionSection.h"
#import "P2CollectionChangeSet.h"
#import "ATScheduling.h"


NSString *const P2CollectionPresentationDidChangeNotification = @"P2CollectionPresentationDidChange";
NSString *const P2CollectionPresentationChangeSetKey = @"changeset";


@implementation P2CollectionPresentation {
    NSDictionary *_visibleSectionsByGroupingValue;
    ATCoalescedState _reloadDataState;
}

- (void)dealloc {
    [self bindToModel:nil keyPath:nil modelDidChangeNotificationName:nil];
}


#pragma mark - Observation Helpers

- (void)bindToModel:(NSObject *)model keyPath:(NSString *)keyPath {
    [self bindToModel:model keyPath:keyPath modelDidChangeNotificationName:nil];
}

- (void)bindToModel:(NSObject *)model keyPath:(NSString *)keyPath modelDidChangeNotificationName:(NSString *)modelDidChangeNotificationName {
    if (_model && _keyPath) {
        if (_modelDidChangeNotificationName) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_modelDidChangeNotificationName object:nil];
        } else {
            [_model removeObserver:self forKeyPath:_keyPath];
        }
    }

    _model = model;
    _keyPath = keyPath;
    _modelDidChangeNotificationName = modelDidChangeNotificationName;

    if (_model && _keyPath) {
        if (_modelDidChangeNotificationName) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_modelDidChange:) name:_modelDidChangeNotificationName object:nil];
        } else {
            [_model addObserver:self forKeyPath:_keyPath options:0 context:NULL];
        }
    }

    [self _updateObjectsFromModel];
}

- (void)_modelDidChange:(NSNotification *)notification {
    if (notification.object == nil || notification.object == _model) {
        [self _updateObjectsFromModel];
    }
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
    [predefinedSections enumerateObjectsUsingBlock:^(P2CollectionSection *section, NSUInteger idx, BOOL *stop) {
        if (!section.identifier) {
            section.identifier = [NSString stringWithFormat:@"predefined-%d", (int)idx];
        }
    }];

    _predefinedSections = [predefinedSections copy];
}

- (void)setItemFilteringPredicate:(NSPredicate *)itemFilteringPredicate {
    if (_itemFilteringPredicate != itemFilteringPredicate) {
        _itemFilteringPredicate = itemFilteringPredicate;
        [self reloadData];
    }
}


#pragma mark - The core :-)

- (void)setObjects:(NSArray *)objects {
    _objects = [objects copy];
    [self reloadData];
}

- (void)reloadData {
    AT_dispatch_coalesced(&_reloadDataState, 0, ^(dispatch_block_t done) {
        [self _doReloadData];
        done();
    });
}

- (void)_doReloadData {
    NSArray *oldVisibleSections = _visibleSections;
    NSDictionary *oldLookupCache = [self lookupCacheForItemsInSections:oldVisibleSections];
    NSDictionary *oldSectionsByIdentifierOrGroupingValue = [self indexSectionsByIdentifierOrGroupingValue:oldVisibleSections];
    NSDictionary *oldItemsBySection = [self itemsGroupedBySectionInSections:oldVisibleSections];

    NSArray *objects = _objects;

    _visibleSections = [self visibleSectionsForObjects:objects];
    _visibleSectionsByGroupingValue = [self indexSectionsByGroupingValue:_visibleSections];

    NSLog(@"New visibleSections = %@", _visibleSections);

    P2CollectionChangeSet *changeset = [[P2CollectionChangeSet alloc] init];
    if (oldVisibleSections) {
        NSDictionary *newLookupCache = [self lookupCacheForItemsInSections:_visibleSections];
        NSDictionary *newSectionsByIdentifierOrGroupingValue = [self indexSectionsByIdentifierOrGroupingValue:_visibleSections];

        NSMutableArray *indexPathsOfAddedItems = [NSMutableArray new];
        NSMutableArray *existingItems = [NSMutableArray new];
        NSMutableArray *indexPathsOfRemovedItems = [NSMutableArray new];
        NSMutableIndexSet *indexesOfAddedSections = [NSMutableIndexSet new];
        NSMutableIndexSet *indexesOfRemovedSections = [NSMutableIndexSet new];

        [_visibleSections enumerateObjectsUsingBlock:^(P2CollectionSection *section, NSUInteger sectionIndex, BOOL *stop) {
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

        [oldVisibleSections enumerateObjectsUsingBlock:^(P2CollectionSection *section, NSUInteger oldSectionIndex, BOOL *stop) {
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

    [[NSNotificationCenter defaultCenter] postNotificationName:P2CollectionPresentationDidChangeNotification
                                                        object:self
                                                      userInfo:@{P2CollectionPresentationChangeSetKey: changeset}];
}

- (void)finalizeSection:(P2CollectionSection *)section items:(NSArray *)items {
    if (_itemFilteringPredicate) {
        items = [items filteredArrayUsingPredicate:_itemFilteringPredicate];
    }
    section.items = items;
}

- (NSArray *)visibleSectionsForObjects:(NSArray *)objects {
    NSMutableArray *visibleSections = [NSMutableArray new];
    NSArray *remainingObjects = objects;

    if (_itemSortDescriptors.count > 0) {
        remainingObjects = [remainingObjects sortedArrayUsingDescriptors:_itemSortDescriptors];
    }

    for (P2CollectionSection *section in _predefinedSections) {
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

        [self finalizeSection:section items:selectedItems];
        remainingObjects = [remainingObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ![selectedItems containsObject:evaluatedObject];
        }]];

        if (_sectionConfigurationBlock) {
            _sectionConfigurationBlock(section);
        }

        if (selectedItems.count > 0) {
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
                P2CollectionSection *section = [self newSectionForGroupingValue:groupingValue];
                [self finalizeSection:section items:groupedItems[groupingValue]];
                if (_dynamicSectionConfigurationBlock) {
                    _dynamicSectionConfigurationBlock(section);
                }
                if (_sectionConfigurationBlock) {
                    _sectionConfigurationBlock(section);
                }
                [visibleSections addObject:section];
            }
        } else {
            P2CollectionSection *section = [self newSectionForGroupingValue:nil];
            [self finalizeSection:section items:remainingObjects];
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

    [visibleSections enumerateObjectsUsingBlock:^(P2CollectionSection *section, NSUInteger idx, BOOL *stop) {
        section.visibleSectionIndex = idx;
    }];

    return [visibleSections copy];
}

- (P2CollectionSection *)newSectionForGroupingValue:(id)groupingValue {
    P2CollectionSection *section = _visibleSectionsByGroupingValue[groupingValue ?: [NSNull null]];
    if (!section) {
        section = [P2CollectionSection new];
        section.groupingValue = groupingValue;
    }
    return section;
}

- (NSDictionary *)lookupCacheForItemsInSections:(NSArray *)sections {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [sections enumerateObjectsUsingBlock:^(P2CollectionSection *section, NSUInteger sectionIndex, BOOL *stop) {
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
    for (P2CollectionSection *section in sections) {
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
    for (P2CollectionSection *section in sections) {
        id key = section.identifierOrGroupingValue;
        grouped[key] = section;
    }
    return grouped;
}

- (NSDictionary *)itemsGroupedBySectionInSections:(NSArray *)sections {
    NSMutableDictionary *grouped = [NSMutableDictionary dictionary];
    for (P2CollectionSection *section in sections) {
        id key = section.identifierOrGroupingValue;
        grouped[key] = section.items;
    }
    return grouped;
}

#pragma mark - Outputs

- (NSArray *)visibleItems {
    return [_visibleSections.firstObject items];
}

@end
