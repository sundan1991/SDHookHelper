//
//  SuperTestClass.h
//  AspectHookDemo
//
//  Created by suapri on 2018/7/30.
//  Copyright © 2018年 MLJR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuperTestClass : NSObject

- (void)testMethod:(NSString *)name;
- (void)oldMethod:(NSString *)methodName
             name:(NSString *)name
              age:(int)age;

@end
