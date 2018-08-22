//
//  NSObject+SDHookHelper.h
//  Created by suapri on 2018/7/30.
//  Copyright © 2018年 MLJR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SDHookHelper)

typedef NS_ENUM(NSUInteger, SDHookType) {
    SDHookTypeReplace,
    SDHookTypeBefore,
    SDHookTypeAfter
};

- (void)sd_hookBlk:(id)oldBlk
            newBlk:(id)newBlk
          hookType:(SDHookType)hookType;

- (void)sd_hookMethod:(SEL)oldMethod
            newMethod:(SEL)newMethod
       newMethodClass:(Class)newCls
             hookType:(SDHookType)hookType;

- (void)sd_hookMethod:(SEL)method
                block:(id)blk
             hookType:(SDHookType)hookType;

@end


