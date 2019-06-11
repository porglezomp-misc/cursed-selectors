#import "ConstLang.h"
#import <objc/runtime.h>

@implementation ConstLang

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    const char *name = sel_getName(sel);
    NSLog(@"Generating method for selector '%s'\n", name);
    char *rest;
    int value = strtol(name, &rest, 10);
    // Must have parsed something, or have content left in buffer
    if ((value == 0 && rest == name) || *rest != '\0') {
        return NO;
    }
    IMP impl = imp_implementationWithBlock(^(id self) { return value; });
    class_addMethod(self, sel_registerName(name), impl, "i@:");
    return YES;
}

@end
