//
//  SuperTestClass.m
//  AspectHookDemo
//
//  Created by suapri on 2018/7/30.
//  Copyright © 2018年 MLJR. All rights reserved.
//

#import "SuperTestClass.h"

@implementation SuperTestClass

- (void)testMethod:(NSString *)name {
    NSLog(@"====super test class testMethod");
}

- (void)oldMethod:(NSString *)methodName
             name:(NSString *)name
              age:(int)age {
    NSLog(@"super oldMethod===%@===%@===%d",methodName,name,age);
}

@end
