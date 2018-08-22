
typedef NS_ENUM(NSUInteger, SDHookType) {\n
    SDHookTypeReplace,\n
    SDHookTypeBefore,\n
    SDHookTypeAfter\n
};\n
\n
- (void)sd_hookBlk:(id)oldBlk\n
            newBlk:(id)newBlk\n
          hookType:(SDHookType)hookType;\n
\n
- (void)sd_hookMethod:(SEL)oldMethod\n
            newMethod:(SEL)newMethod\n
       newMethodClass:(Class)newCls\n
             hookType:(SDHookType)hookType;\n
\n
- (void)sd_hookMethod:(SEL)method\n
                block:(id)blk\n
             hookType:(SDHookType)hookType;\n
