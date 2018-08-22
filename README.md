
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
