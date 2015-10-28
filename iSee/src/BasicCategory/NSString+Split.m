//
//  NSString+Split.m
//  iSee
//
//  Created by Yangtsing.Zhang on 15/10/22.
//  Copyright © 2015年 ___Baidu Inc.___. All rights reserved.
//

#import "NSString+Split.h"

@implementation NSString (Split)

- (NSArray *)stringsSplitByWhiteSpace
{
    NSMutableArray <__kindof NSString*> *tmpArray = [NSMutableArray arrayWithCapacity:8];
    NSString *aString = nil;
    NSUInteger startIndex = 0;
    NSUInteger endIndex = 0;
    char curWord = ' ';
    char lastWord = ' ';
    if (self && ![self isEqualToString:@""]) {
        for (int i = 0; i < [self length]; ++i) {
            curWord = [self characterAtIndex: i];
            if (lastWord == ' ' && curWord != ' ') {//一段连续string的开始
                startIndex = i;
                lastWord = curWord;
                continue;
            }
            
            if (lastWord != ' ' && curWord == ' ') {//一段连续string的结束
                endIndex = i;
                lastWord = curWord;
                if (endIndex > startIndex) {
                    NSUInteger length = endIndex - startIndex + 1;
                    NSRange range = NSMakeRange(startIndex, length);
                    aString = [self substringWithRange: range];
                    [tmpArray addObject: aString];
                }
                continue;
            }
            
            if (i == ([self length] - 1)) { //到最后一个字符
                if (lastWord != ' ') {
                    aString = [self substringFromIndex: startIndex];
                    [tmpArray addObject: aString];
                }
            }
        }
    }
    
    return [NSArray arrayWithArray: tmpArray];
}

@end
