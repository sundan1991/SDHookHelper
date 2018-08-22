//
//  NSObject+SDHookHelper.m
//  Created by suapri on 2018/7/30.
//  Copyright © 2018年 MLJR. All rights reserved.
//

#import "NSObject+SDHookHelper.h"
#import <objc/message.h>

#define SD_SET_NEW_BLK(blk) do{hookBlkWithBlk_newBlock = blk;}while(0)
#define SD_SET_OLD_BLK(blk) do{hookBlkWithBlk_oldBlock = blk;}while(0)

#define SD_SET_OLD_FUNC_INVOKE(blk_imp) do{hookBlkWithBlk_old_func = Block_copy(blk_imp->invoke);}while(0)
#define SD_SET_NEW_FUNC_INVOKE(blk_imp) do{hookBlkWithBlk_new_func = Block_copy(blk_imp->invoke);}while(0)

#define SD_RETURN_NIL_METHOD(ruturn_type,obj,...) do{if (!obj||!__VA_ARGS__) return ruturn_type;}while(0)

#define SD_SET_ARGUMENT(type) do {type arg = va_arg(sigArgument,type); if(new_invocation.methodSignature.numberOfArguments>index){[new_invocation setArgument:&arg atIndex:index];} if(old_invocation.methodSignature.numberOfArguments>index){[old_invocation setArgument:&arg atIndex:index];}} while(0)

#define SD_ARGUTYPE_COLLAT(invocation) do{while (invocation.methodSignature.numberOfArguments >index) {const char *type = [invocation.methodSignature getArgumentTypeAtIndex:index];if (strcmp(type, @encode(long long)) == 0) {SD_SET_ARGUMENT(long long);} else if (strcmp(type, @encode(int)) == 0) {SD_SET_ARGUMENT(int);}  else if (strcmp(type, @encode(long)) == 0) {SD_SET_ARGUMENT(long);}  else if (strcmp(type, @encode(unsigned int)) == 0) {SD_SET_ARGUMENT(unsigned int);} else if (strcmp(type, @encode(unsigned long)) == 0) {SD_SET_ARGUMENT(unsigned long);} else if (strcmp(type, @encode(unsigned long long)) == 0) {SD_SET_ARGUMENT(unsigned long long);} else if (strcmp(type, @encode(double)) == 0) {SD_SET_ARGUMENT(double);} else if (strcmp(type, @encode(char *)) == 0) {SD_SET_ARGUMENT(const char *);}else{SD_SET_ARGUMENT(id);}index++;} }while(0)

#define SD_HOOKMETHODWITHBLOCK_SETARGUMTN(type) do{type define_arg = va_arg(args,type);[old_invo setArgument:&define_arg atIndex:i-1];if(sd_globalHook_methodType == SDHookMethodTypeHookMethodWithBlk){if(hookMethodWithBlk_argment_num > i-2){ [invo setArgument:&define_arg atIndex:i-2];}}else{if(seq.numberOfArguments > i-1){ [invo setArgument:&define_arg atIndex:i-1];}}}while(0)

#define SD_HOOKMETHODWITHBLOCK_COLLAT do{while (i<hookMethodWithBlk_argment_num){NSString *ty = [NSString stringWithUTF8String:old_type];if (ty.length == i) break;NSString *str = [ty substringWithRange:NSMakeRange(i, 1)];const char *type = [str UTF8String];if (strcmp(type, @encode(long long)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(long long);} else if (strcmp(type, @encode(int)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(int);}  else if (strcmp(type, @encode(long)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(long);}  else if (strcmp(type, @encode(unsigned int)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(unsigned int);} else if (strcmp(type, @encode(unsigned long)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(unsigned long);} else if (strcmp(type, @encode(unsigned long long)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(unsigned long long);} else if (strcmp(type, @encode(double)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(double);} else if (strcmp(type, @encode(char *)) == 0) {SD_HOOKMETHODWITHBLOCK_SETARGUMTN(const char *);}else{SD_HOOKMETHODWITHBLOCK_SETARGUMTN(id);}i++;}}while(0)

typedef NS_ENUM(NSUInteger, SDHookMethodType) {
    SDHookMethodTypeHookBlkWithBlk,
    SDHookMethodTypeHookMethodWithMethod,
    SDHookMethodTypeHookMethodWithBlk
};

typedef NS_ENUM(int,SDBlkImpFlagsType) {
    SDBlkImpFlagsTypeCopy = (1 << 25),
    SDBlkImpFlagsTypeSign = (1 << 30)
};

typedef struct Block_descriptor {
    unsigned long int reserved;
    unsigned long int size;
    void (*copy_helper)(void *dst, void *src);
    void (*dispose_helper)(void *src);
    const char *signature;
}Block_descriptor;

typedef struct Block_layout {
    void *isa;
    SDBlkImpFlagsType Flags;
    int Reserved;
    void (*invoke)(void *, ...);
    Block_descriptor *block_descriptor;
}Block_layout;

@implementation NSObject (SDHookHelper)

void (*hookBlkWithBlk_new_func)(void *v,...);
void (*hookBlkWithBlk_old_func)(void *v,...);

id hookBlkWithBlk_oldBlock;
id hookBlkWithBlk_newBlock;

SEL sd_hook_sel_oldM;
SEL sd_hook_sel_newM;

int hookMethodWithBlk_argment_num = 0;
Method hookMethodWithBlk_argment_m;

SDHookMethodType hookMethodType;

#pragma mark - Hook Block With Block

- (void)sd_hookBlk:(id)oldBlk
            newBlk:(id)newBlk
          hookType:(SDHookType)hookType {
    SD_RETURN_NIL_METHOD(,oldBlk,newBlk);
    hookMethodType = SDHookMethodTypeHookBlkWithBlk;
    Block_layout *impl = sd_get_Blk_Layout(oldBlk);
    Block_layout *nImpl = sd_get_Blk_Layout(newBlk);
    if (hookType == SDHookTypeReplace){
        impl->invoke = nImpl->invoke;
    }
    else {
        SD_SET_OLD_BLK(oldBlk);
        SD_SET_NEW_BLK(newBlk);
        if (hookType == SDHookTypeAfter) {
            SD_SET_OLD_FUNC_INVOKE(impl);
            SD_SET_NEW_FUNC_INVOKE(nImpl);
        }else{
            SD_SET_OLD_FUNC_INVOKE(nImpl);
            SD_SET_NEW_FUNC_INVOKE(impl);
        }
        impl->invoke = &sd_hookBlkWithBlk_copyBlkMethod;
    }
}

- (void)sd_hookMethod:(SEL)oldMethod
            newMethod:(SEL)newMethod
       newMethodClass:(Class)newCls
             hookType:(SDHookType)hookType {
    
    [self sd_gloabl_hookMethod_method:oldMethod newBlk:nil newSEL:newMethod newCls:newCls hookType:hookType hookMethodType:SDHookMethodTypeHookMethodWithMethod];
}

- (void)sd_hookMethod:(SEL)method
                block:(id)blk
             hookType:(SDHookType)hookType {
    
    [self sd_gloabl_hookMethod_method:method newBlk:blk newSEL:nil newCls:nil hookType:hookType hookMethodType:SDHookMethodTypeHookMethodWithBlk];
    
}

static Block_layout *sd_get_Blk_Layout (id blk) {
    if (!blk) return nil;
    return (__bridge Block_layout*)blk;
}

static NSMethodSignature *sd_getMethodSignature(const char * methodType) {
    if (!methodType) return nil;
    return [NSMethodSignature signatureWithObjCTypes:methodType];
}

static NSInvocation *sd_getInvocation (id blk,void *func) {
    if (!blk) return nil;
    Block_layout *blk_lay = sd_get_Blk_Layout(blk);
    void *desc = blk_lay->block_descriptor;
    desc += 2*sizeof(long int);
    if (blk_lay->Flags & SDBlkImpFlagsTypeCopy) {
        desc += 2*sizeof(void *);
    }
    const char *hook_method_type = (*(const char **)desc);
    NSMethodSignature *hook_sig = sd_getMethodSignature(hook_method_type);
    if (func) {
        blk_lay->invoke = func;
    }
    return [NSInvocation invocationWithMethodSignature:hook_sig];
}

void sd_hookBlkWithBlk_copyBlkMethod (void *v,...) {
    NSInvocation *old_invocation = sd_getInvocation(hookBlkWithBlk_oldBlock,hookBlkWithBlk_old_func);;
    NSInvocation *new_invocation = sd_getInvocation(hookBlkWithBlk_newBlock,hookBlkWithBlk_new_func);;

    int index = 1;
    va_list sigArgument;
    va_start(sigArgument, v);
    SD_ARGUTYPE_COLLAT(old_invocation);
    va_end(sigArgument);

    [old_invocation invokeWithTarget:hookBlkWithBlk_oldBlock];
    [new_invocation invokeWithTarget:hookBlkWithBlk_newBlock];
}


static NSSet *blackList;
- (BOOL)sd_checkArgumentMethodBlackList {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blackList = [[NSSet alloc] initWithObjects:@"forwardInvocation:",@"retain",@"release",@"autorelease", nil];
    });
    NSString *oldMethodStr = NSStringFromSelector(sd_globalHook_oldSEL);
    if ([blackList containsObject:oldMethodStr]) return NO;
    return YES;
}


- (Class)sd_global_creatSubCls_method {
    NSString *name = [NSString stringWithFormat:@"%@%@",NSStringFromClass([self class]),@"sd_hookMethod_subCls"];
    Class newCls = objc_allocateClassPair([self class], [name UTF8String], 0);
    objc_registerClassPair(newCls);
    object_setClass(self, newCls);
    return newCls;
}

SEL sd_globalHook_oldSEL;
SEL sd_globalHook_newSEL;
id  sd_globalHook_newObj;
Class sd_gloablHook_newCls;
SDHookType sd_globalHook_hookType;
SDHookMethodType sd_globalHook_methodType;

- (void)sd_gloabl_hookMethod_method:(SEL)oldSEL
                             newBlk:(id)newObj
                             newSEL:(SEL)newSEL
                             newCls:(Class)newCls
                           hookType:(SDHookType)hookType
                     hookMethodType:(SDHookMethodType)methodType {
    sd_globalHook_oldSEL = oldSEL;
    if (![self sd_checkArgumentMethodBlackList])return;
    if (!newObj && !newSEL)return;
    sd_globalHook_newObj = newObj;
    sd_globalHook_newSEL = newSEL;
    sd_gloablHook_newCls = newCls;
    sd_globalHook_hookType = hookType;
    sd_globalHook_methodType = methodType;
    class_addMethod([self sd_global_creatSubCls_method], oldSEL, (IMP)sd_hookMethodWithBlk, 0);
}

const char * sd_globalHook_getSEL_type (SEL selector,Class cls) {

    NSMutableString *str = [NSMutableString stringWithString:@"v@:"];
    for (int i = 2; i<method_getNumberOfArguments(class_getInstanceMethod(cls, selector)); i++) {
        char *ar_type = method_copyArgumentType(class_getInstanceMethod(cls, selector), i);
        [str appendString:[NSString stringWithUTF8String:ar_type]];
    }
    return [str UTF8String];
}

void sd_hookMethodWithBlk (id self, SEL _cmd,...) {
    //old
    const char *old_type = sd_globalHook_getSEL_type(sd_globalHook_oldSEL,class_getSuperclass([self class]));
    NSMethodSignature *old_seq = [NSMethodSignature signatureWithObjCTypes:old_type];
    NSInvocation *old_invo = [NSInvocation invocationWithMethodSignature:old_seq];
    old_invo.selector = sd_globalHook_oldSEL;
    hookMethodWithBlk_argment_m = class_getInstanceMethod([self class], sd_globalHook_oldSEL);
    hookMethodWithBlk_argment_num = method_getNumberOfArguments(hookMethodWithBlk_argment_m);
    
    //new
    NSMethodSignature *seq;
    if (sd_globalHook_methodType == SDHookMethodTypeHookMethodWithBlk) {
        Block_layout *blk_lay = (__bridge Block_layout *)sd_globalHook_newObj;
        Block_descriptor *des = blk_lay->block_descriptor;
        seq = [NSMethodSignature signatureWithObjCTypes:(const char *)des->copy_helper];
    }else{
        const char *type = sd_globalHook_getSEL_type(sd_globalHook_newSEL,sd_gloablHook_newCls?sd_gloablHook_newCls:class_getSuperclass([self class]));
        seq = [NSMethodSignature signatureWithObjCTypes:type];
    }
    NSInvocation *invo = [NSInvocation invocationWithMethodSignature:seq];

    va_list args;
    va_start(args, _cmd);
    int i = 3;
    SD_HOOKMETHODWITHBLOCK_COLLAT;
    Class supCls = class_getSuperclass([self class]);
#define SD_OLD_INVOCATION_INVOKE do{[old_invo invokeWithTarget:[[supCls alloc] init]];}while(0)
    
#define SD_NEW_INVOCATION_INVOKE do{[invo invokeWithTarget:sd_gloablHook_newCls?[[sd_gloablHook_newCls alloc] init]:[[supCls alloc] init]];}while(0)
    
#define SD_BLK_INVOKE(blk) do{[invo invokeWithTarget:blk];}while(0)
    if (sd_globalHook_methodType == SDHookMethodTypeHookMethodWithMethod) {
        invo.selector = sd_globalHook_newSEL;
    }
    if (sd_globalHook_hookType == SDHookTypeBefore) {
        if (sd_globalHook_methodType == SDHookMethodTypeHookMethodWithBlk){
            SD_BLK_INVOKE(sd_globalHook_newObj);
        }else
            SD_NEW_INVOCATION_INVOKE;
        SD_OLD_INVOCATION_INVOKE;
    }
    else if (sd_globalHook_hookType == SDHookTypeReplace){
        if (sd_globalHook_methodType == SDHookMethodTypeHookMethodWithBlk){
            SD_BLK_INVOKE(sd_globalHook_newObj);
        }else
            SD_NEW_INVOCATION_INVOKE;
        
    }else{
        SD_OLD_INVOCATION_INVOKE;
        if (sd_globalHook_methodType == SDHookMethodTypeHookMethodWithBlk){
            SD_BLK_INVOKE(sd_globalHook_newObj);
        }
        else
            [invo invokeWithTarget:[[supCls alloc] init]];
    }
    objc_disposeClassPair([self class]);
    object_setClass(self, supCls);
}

@end


