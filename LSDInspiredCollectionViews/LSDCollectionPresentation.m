
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

    // TODO: compute sections
    LSDCollectionSection *section = [LSDCollectionSection new];
    section.items = _objects;
    if (_sectionConfigurationBlock) {
        _sectionConfigurationBlock(section);
    }
    _visibleSections = @[section];

    LSDCollectionChangeSet *changeset = [[LSDCollectionChangeSet alloc] init];
    // TODO diff and stuff

    [[NSNotificationCenter defaultCenter] postNotificationName:LSDCollectionPresentationDidChangeNotification
                                                        object:self
                                                      userInfo:@{LSDCollectionPresentationChangeSetKey: changeset}];
}


#pragma mark - Outputs

@end
