#import "RPNLang.h"
#import <objc/runtime.h>

typedef enum {
    INT,
    VAR,
    ADD,
    SUB,
    MUL,
    DIV,
    REM,
    NEG,
} Tag;

@interface Command : NSObject

@property(readonly) int value;
@property(readonly) Tag tag;

+(instancetype)withTag:(Tag)tag;
+(instancetype)withTag:(Tag)tag value:(int)value;
+(nullable instancetype)withString:(NSString *)string;
-(int)arity;
-(int)results;
-(NSString*)description;

@end

@implementation Command {
}

+(instancetype)withTag:(Tag)tag {
    return [self withTag:tag value:0];
}

+(instancetype)withTag:(Tag)tag value:(int)value {
    Command *instance = [Command new];
    instance->_tag = tag;
    instance->_value = value;
    return instance;
}

+(nullable instancetype)withString:(NSString *)string {
    int value = 0;
    if (string.length == 1) {
        // operators and single digits
        switch ([string characterAtIndex:0]) {
        case '+': return [self withTag:ADD];
        case '-': return [self withTag:SUB];
        case '*': return [self withTag:MUL];
        case '/': return [self withTag:DIV];
        case '%': return [self withTag:REM];
        case '~': return [self withTag:NEG];
        default:
            if (![[NSScanner scannerWithString:string] scanInt:&value]) {
                return nil;
            }
            return [self withTag:INT value:value];
        }
    }

    if ([string hasPrefix:@"$"]) {
        // variables $#, e.g. $0
        if (![[NSScanner scannerWithString:[string substringFromIndex:1]] scanInt:&value]) {
            return nil;
        }
        // negative variable indices are illegal
        if (value < 0) { return nil; }
        return [self withTag:VAR value:value];
    } else {
        // numbers #, e.g. 0
        if (![[NSScanner scannerWithString:string] scanInt:&value]) {
            return nil;
        }
        return [self withTag:INT value:value];
    }
}

-(int)arity {
    switch (self.tag) {
    case VAR: case INT: return 0;
    case NEG: return 1;
    default: return 2;
    }
}

-(int)results {
    return 1;
}

-(NSString*)description {
    switch (self.tag) {
    case INT: return [NSString stringWithFormat:@"%d", self.value];
    case VAR: return [NSString stringWithFormat:@"$%d", self.value];
    case ADD: return @"+";
    case SUB: return @"-";
    case MUL: return @"*";
    case DIV: return @"/";
    case REM: return @"%";
    case NEG: return @"~";
    }
}

-(void)operateOnStack:(NSMutableArray<NSNumber*>*)stack {
    [self operateOnStack:stack env:@[]];
}

-(void)operateOnStack:(NSMutableArray<NSNumber*>*)stack env:(NSArray<NSNumber*>*)env {
#define BINOP(A, B, X) { \
    NSNumber *A = [stack lastObject]; [stack removeLastObject]; \
    NSNumber *B = [stack lastObject]; [stack removeLastObject]; \
    [stack addObject:[NSNumber numberWithInt:(X)]]; \
    break; }

    switch (self.tag) {
    case INT:
        [stack addObject:[NSNumber numberWithInteger:self.value]];
        break;
    case VAR:
        [stack addObject:[env objectAtIndex:self.value]];
        break;
    case ADD: BINOP(a, b, a.intValue + b.intValue);
    case SUB: BINOP(a, b, a.intValue - b.intValue);
    case MUL: BINOP(a, b, a.intValue * b.intValue);
    case DIV: BINOP(a, b, a.intValue / b.intValue);
    case REM: BINOP(a, b, a.intValue % b.intValue);
    case NEG: {
        NSNumber *val = [stack lastObject]; [stack removeLastObject];
        [stack addObject:[NSNumber numberWithInt:-val.intValue]];
        break;
    }
    }

#undef BINOP
}



@end


@implementation RPNLang

/*
-(void)forwardInvocation:(NSInvocation *)invocation {
    const char *name = sel_getName(invocation.selector);
    NSString *sName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    NSArray<NSString*> *parts = [sName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    parts = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    sName = [parts componentsJoinedByString:@" "];
    NSLog(@"Forwarding invocation %s to %@\n", name, sName);
    invocation.selector = sel_registerName([sName cStringUsingEncoding:NSUTF8StringEncoding]);
    [invocation invoke];
}
*/

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    const char *name = sel_getName(sel);
    NSString *sName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    NSArray<NSString*> *parts = [sName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    parts = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    // sName = [parts componentsJoinedByString:@" "];
    NSLog(@"Compiling selector %s\n", name);

    // Let's parse the argument list!
    int stackSize = 0;
    int numArguments = 0;
    NSMutableArray<Command*> *code = [NSMutableArray new];
    for (NSString *part in parts) {
        Command *command = [Command withString:part];
        if (command == nil) { return NO; }
        stackSize -= [command arity];
        if (stackSize < 0) { return NO; }
        stackSize += [command results];
        [code addObject:command];
        if (command.tag == VAR) {
            numArguments = MAX(numArguments, command.value+1);
        }
    }
    if (stackSize != 1) { return NO; }

    if (numArguments != 0) {
        IMP impl = imp_implementationWithBlock(^int (RPNLang *self, NSArray<NSNumber *> *params) {
            NSMutableArray<NSNumber*> *stack = [NSMutableArray new];
            for (Command *inst in code) {
                [inst operateOnStack:stack env:params];
            }
            return [stack firstObject].intValue;
        });
            // FINALLY!
    // @TODO: use the normalized method name, redirect from there
    // [sName cStringUsingEncoding:NSUTF8StringEncoding]
    class_addMethod(self, sel_registerName(name), impl, "i@:@");
    return YES;

    } else {
        IMP impl = imp_implementationWithBlock(^int (RPNLang *self) {
            NSMutableArray<NSNumber*> *stack = [NSMutableArray new];
            for (Command *inst in code) {
                [inst operateOnStack:stack];
            }
            return [stack firstObject].intValue;
        });
        class_addMethod(self, sel_registerName(name), impl, "i@:");
        return YES;
    }


}

@end
