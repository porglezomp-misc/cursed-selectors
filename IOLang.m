#import "IOLang.h"
#import <objc/runtime.h>

#include <io/IoState.h>

@implementation IOLang {
    IoState *ioState;
}

-(instancetype)init {
    self->ioState = IoState_new();
    IoState_init(self->ioState);
    return self;
}

-(void)deinit {
    IoState_free(self->ioState);
    self->ioState = nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

-(void)forwardInvocation:(NSInvocation *)invocation {
    const char *code = sel_getName(invocation.selector);
    NSLog(@"%s\n", code);
    IoState_doCString_(self->ioState, code);
}

@end
