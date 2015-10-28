//
//  ObjectFileItem.m
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/11.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import "ObjectFileItem.h"

@interface ObjectFileItem()

@property (nonatomic, retain) NSMutableArray<__kindof MethodFileItem*> *methodsArray;

@end

@implementation ObjectFileItem

- (long int)totalMethodsSize
{
    NSEnumerator *enumerator = [_methodsArray objectEnumerator];
    MethodFileItem *methodItem = nil;
    long int totalFuncSize = 0;
    while (methodItem = [enumerator nextObject]) {
        totalFuncSize += methodItem.size;
    }
    _funcSize = totalFuncSize;
    return totalFuncSize;
}

- (void)addMethodObject:(MethodFileItem *)methodObj
{
    _funcSize += methodObj.size;
    
    [_methodsArray addObject: methodObj];
}

@end
