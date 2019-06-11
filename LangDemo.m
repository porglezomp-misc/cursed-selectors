#import "ConstLang.h"

int main() {
    ConstLang *constant = [ConstLang new];
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"413")]);
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"413")]);
    NSLog(@"%d\n", (int)[constant performSelector: NSSelectorFromString(@"612")]);
}
