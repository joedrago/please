#import "include/ObjCExceptionCatcher.h"

BOOL ObjCTryEval(id _Nullable (^block)(void), id _Nullable *outResult) {
    @try {
        id result = block();
        if (outResult) *outResult = result;
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
}
