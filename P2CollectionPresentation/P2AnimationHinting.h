
#import <Foundation/Foundation.h>

typedef enum {
    P2AnimationHintNone = -1,
    P2AnimationHintUndefined = 0,
    P2AnimationHintInitialLoad = 10,
    P2AnimationHintFiltering = 20,
    P2AnimationHintModelAction = 30,
} P2AnimationHint;

P2AnimationHint P2AnimationHintGetCurrent();
void P2AnimationHintApply(P2AnimationHint hint);
