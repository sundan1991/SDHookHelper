//
//  ViewController.m
//  SDHookHelper
//
//  Created by suapri on 2018/8/22.
//

#import "ViewController.h"
#import "TestClass.h"
#import "NSObject+SDHookHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //hook block with block
    __block int a  = 1;
    void (^blk)(NSDictionary *,CGFloat,NSString * ,NSInteger) = ^(NSDictionary *name,CGFloat i,NSString *age,NSInteger num){
        a = 2;
        NSLog(@"hook blk with blk _  new blk");
    };
    [self sd_hookBlk:blk newBlk:^(NSDictionary *dic){
        a = 3;
    } hookType:SDHookTypeBefore];
    blk(@{@"key":@"value"},55,@"111",111);

    //hook method with method
    [self sd_hookMethod:@selector(oldMethod:age:address:other:) newMethod:@selector(hhhh:age:address:) newMethodClass:nil hookType:SDHookTypeAfter];
    [self oldMethod:@"sundansundan" age:12 address:@"北京朝阳" other:@{@"key":@"value"}];

    //hook method with block
    TestClass *testClass = [[TestClass alloc] init];
    [testClass sd_hookMethod:@selector(oldMethod:name:age:) block:^(NSString *methodname,NSString *name,int age){
        NSLog(@"hook method with blk _  new blk");

    } hookType:SDHookTypeAfter];

    [testClass oldMethod:@"oldMethod" name:@"sudan" age:18];
}

- (void)oldMethod:(NSString *)methodName
             name:(NSString *)name
              age:(int)age {
    NSLog(@"oldMethod:name:age");
}

- (void)oldMethod:(NSString *)name
              age:(NSInteger)age
          address:(NSString *)adr
            other:(NSDictionary *)dic {
    NSLog(@"oldMethod:age:address:other");
}

- (void)hhhh:(NSString *)name
         age:(NSInteger)age
     address:(NSString *)adr {
    NSLog(@"hhhh:age:address");
}


@end
