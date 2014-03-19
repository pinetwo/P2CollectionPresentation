
#import "P2AnimationHinting.h"

static P2AnimationHint g_animationHint = P2AnimationHintUndefined;
static uint64_t g_animationHintResetSequence = 0;

P2AnimationHint P2AnimationHintGetCurrent() {
    return g_animationHint;
}

static void P2AnimationHintScheduleReset() {
    uint64_t sequence = g_animationHintResetSequence++;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (sequence == g_animationHintResetSequence) {
            g_animationHint = P2AnimationHintUndefined;
        }
    });
}

void P2AnimationHintApply(P2AnimationHint hint) {
    if (g_animationHint < 0 || hint < 0)
        g_animationHint = MIN(g_animationHint, hint);
    else
        g_animationHint = MAX(g_animationHint, hint);

    P2AnimationHintScheduleReset();
}
