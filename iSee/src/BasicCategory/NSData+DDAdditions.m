//
//  NSData+DDAdditions.m
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/26.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import "NSData+DDAdditions.h"

@implementation NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind {
    
    const void * bytes = [self bytes];
    NSUInteger length = [self length];
    
    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;
    
    NSRange foundRange = {NSNotFound, searchLength};
    for (NSUInteger index = 0; index < length; index++) {
        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex]) {
            //the current character matches
            if (foundRange.location == NSNotFound) {
                foundRange.location = index;
            }
            searchIndex++;
            if (searchIndex >= searchLength) { return foundRange; }
        } else {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}

- (NSRange) rangeOfLastData_dd:(NSData *)dataToFind
{
    if (!dataToFind) {
        @throw NSInvalidArgumentException;
        return NSMakeRange(NSNotFound, 0);
    }
    const void * bytes = [self bytes];
    NSUInteger length = [self length];
    
    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSInteger searchIndex = searchLength - 1;
    
    NSRange foundRange = {NSNotFound, searchLength};
    for (NSInteger index = length - 1; index >= 0; index--) {
        if (((char *)bytes)[index] ==  ((char *)searchBytes)[searchIndex]) {
            if (foundRange.location == NSNotFound) {
                foundRange.location = (NSUInteger)index;
            }
            searchIndex--;
            if (searchIndex < 0) {//finish string match
                return foundRange;
            }
        }else{
            searchIndex = searchLength - 1;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}

@end
