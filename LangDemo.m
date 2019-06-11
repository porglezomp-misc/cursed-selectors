#import "ConstLang.h"
#import "RPNLang.h"

int main() {
    ConstLang *constant = [ConstLang new];
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"413")]);
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"413")]);
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"612")]);

    RPNLang *rpn = [RPNLang new];
    NSLog(@"%d\n", (int)[rpn performSelector: NSSelectorFromString(@"1 2  +")]);
    NSLog(@"%d\n", (int)[rpn performSelector: NSSelectorFromString(@"1 2  +")]);
    NSLog(@"%d\n", (int)[rpn performSelector: NSSelectorFromString(@"$0 $1 +") withObject:@[@413, @612]]);
}
