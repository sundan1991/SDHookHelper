//
//  TestClass.h
//  AspectHookDemo
//
//  Created by suapri on 2018/7/24.
//  Copyright © 2018年 MLJR. All rights reserved.
//

#import "SuperTestClass.h"

@interface TestClass : SuperTestClass

- (void)oldTestMethod:(NSString *)name;
- (void)newTestMethod:(NSString *)name;
- (void)oldMethod:(NSString *)methodName
             name:(NSString *)name
              age:(int)age;

@end
