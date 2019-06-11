#import "ConstLang.h"
#import "RPNLang.h"
#import "IOLang.h"

int main() {
    ConstLang *constant = [ConstLang new];
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"413")]);
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"413")]);
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"612")]);

    RPNLang *rpn = [RPNLang new];
    NSLog(@"%d\n", (int)[rpn performSelector: NSSelectorFromString(@"1 2  +")]);
    NSLog(@"%d\n", (int)[rpn performSelector: NSSelectorFromString(@"1 2  +")]);
    NSLog(@"%d\n", (int)[rpn performSelector: NSSelectorFromString(@"$0 $1 +") withObject:@[@413, @612]]);

    IOLang *io = [IOLang new];
    [io performSelector:NSSelectorFromString(@"writeln(\"hello world!\")")];
    [io performSelector:NSSelectorFromString(@"for(i, 1, 10, \n"
        @"if(i == 3, continue)\n"
        @"if(i == 7, break)\n"
        @"i print\n"
    @")")];
}
