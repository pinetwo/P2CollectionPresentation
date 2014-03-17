
#import "LSDCollectionPresentation.h"
#import "LSDCollectionSection.h"
#import "LSDCollectionChangeSet.h"


NSString *const LSDCollectionPresentationDidChangeNotification = @"LSDCollectionPresentationDidChange";
NSString *const LSDCollectionPresentationChangeSetKey = @"changeset";


@implementation LSDCollectionPresentation

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


#pragma mark - The core :-)

- (void)setObjects:(NSArray *)objects {
    _objects = [objects copy];

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
            section.sectionIndex = NSIntegerMin;
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
                LSDCollectionSection *section = [LSDCollectionSection new];
                section.items = groupedItems[groupingValue];
                section.groupingValue = groupingValue;
                if (_dynamicSectionConfigurationBlock) {
                    _dynamicSectionConfigurationBlock(section);
                }
                if (_sectionConfigurationBlock) {
                    _sectionConfigurationBlock(section);
                }
                [visibleSections addObject:section];
            }
        } else {
            LSDCollectionSection *section = [LSDCollectionSection new];
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

    _visibleSections = [visibleSections copy];

    LSDCollectionChangeSet *changeset = [[LSDCollectionChangeSet alloc] init];
    // TODO diff and stuff

    [[NSNotificationCenter defaultCenter] postNotificationName:LSDCollectionPresentationDidChangeNotification
                                                        object:self
                                                      userInfo:@{LSDCollectionPresentationChangeSetKey: changeset}];
}


#pragma mark - Outputs

@end
