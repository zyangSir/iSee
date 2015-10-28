//
//  GSLinkMapParser.h
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/27.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDFileReader.h"

@interface GSLinkMapParser : NSObject

@property (nonatomic, weak) DDFileReader *linkMapfileReader;

/**
 *  判断读取的一行log是否是目标文件log,段表log,符号表的开始标记
 *
 *  @param aLineStr 一行log
 *
 *  @return YES:是 NO:否
 */
- (BOOL)isSectionStartFlag:(NSString *)aLineStr;

/**
 *  根据linkMap 不同段的标识字符串 开始对不同section的log解析
 *
 *  @param aLineStr 可能是:目标文件段, 段表段, 符号段
 */
- (void)startSubParserWithStartFlag:(NSString *)aLineStr;

- (NSString *)lastLinkMapLineLog;

- (void)outputObjectFileSize;

@end
