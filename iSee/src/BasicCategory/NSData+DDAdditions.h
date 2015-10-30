//
//  NSData+DDAdditions.h
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/26.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind;


/**
 *  Finds and returns the range of the last occurrence of a given data within the receiver.
 *
 *  @param dataToFind  The data to search for. This value must not be nil.Raises an NSInvalidArgumentException if dataToFind is nil.
 *
 *  @return Returns	An NSRange structure giving the location and length in the receiver of the first occurrence of dataToFind.
 */

- (NSRange) rangeOfLastData_dd:(NSData *)dataToFind;

@end
