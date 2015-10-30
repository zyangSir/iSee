//
//  GSLinkMapParser.m
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/27.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import "GSLinkMapParser.h"
#import "GSCommonDefine.h"
#import "DDFileReader.h"
#import "ObjectFileItem.h"
#import "ExecutableCodeItem.h"
#import "NSString+Split.h"

#define SYSTEM_LIB_PATH_PREFIX @"/Applications/Xcode.app/"
#define CUSTOM_LIB_PATH_PREFIX @"/Users/"

@interface GSLinkMapParser()

@property (nonatomic, retain) NSString *lastLineStr;

/**
 *  目标文件数组
 */
@property (nonatomic, retain) NSArray <__kindof ObjectFileItem*> *objectFileArray;

/**
 *  可执行代码段项目
 */
@property (nonatomic, retain) NSArray <__kindof ExecutableCodeItem*> *executableCodeArray;

@end

@implementation GSLinkMapParser

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - getters

- (NSString *)lastLinkMapLineLog
{
    return self.lastLineStr;
}

#pragma mark - outer interface

- (BOOL)isSectionStartFlag:(NSString *)aLineStr
{
    BOOL ret = NO;
    if (aLineStr) {
        if ([aLineStr isEqualToString: OBJECT_FILE_LOG_START_FLAG]) {
            ret = YES;
        }else if ([aLineStr isEqualToString: SECTION_TABLE_START_FLAG])
        {
            ret = YES;
        }else if ([aLineStr isEqualToString: SYMBOLS_FILE_LOG_START_FLAG])
        {
            ret = YES;
        }
    }
    return ret;
}

- (void)startSubParserWithStartFlag:(NSString *)aLineStr
{
    [_linkMapfileReader readLine]; //跳过一行
    
    if ([aLineStr isEqualToString: OBJECT_FILE_LOG_START_FLAG]) {
        [self parseObjectFileLog];
    }else if ([aLineStr isEqualToString: SECTION_TABLE_START_FLAG])
    {
        [self parseSectionTableLog];
    }else
    {
        
        [self parseSymbolTableLog];
    }
}

- (void)outputObjectFileSize
{
    [[NSNotificationCenter defaultCenter] postNotificationName: RESULTS_DONE_NOTIFICATION object:_objectFileArray];
}

#pragma mark - inner logic

/**
 *  解析目标文件log
 */
- (void)parseObjectFileLog
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity: 100];
    ObjectFileItem *firstObjectFile = [[ObjectFileItem alloc] init];
    firstObjectFile.fileType = OBJECT_FILE_FROM_INVALID_VAL;
    [tmpArray addObject: firstObjectFile];
    
    ObjectFileItem *dTraceObject = [[ObjectFileItem alloc] init];
    dTraceObject.fileType = OBJECT_FILE_FROM_INVALID_VAL;
    [tmpArray addObject: dTraceObject];
    
    //普通工程代码(开发者自行创建的)
    
    //第三方静态库
    
    //系统库
    self.lastLineStr = [_linkMapfileReader readLine];
    while (![self isSectionStartFlag: _lastLineStr]) {//如果没检测到下一段不同类型log的起始标识串，则继续
        NSRange range = [_lastLineStr rangeOfString:@"/"];
        if (range.location != NSNotFound) {
            NSString *pathStr  = [_lastLineStr substringFromIndex:range.location];
            ObjectFileItem * objFileItem = [[ObjectFileItem alloc] init];
            NSString * objectFileName = [pathStr lastPathComponent];
            
            if ([pathStr hasPrefix: CUSTOM_LIB_PATH_PREFIX]) {
                NSRange bracketRange = [objectFileName rangeOfString: @"("];
                if (bracketRange.location != NSNotFound ) {
                    //静态库中的目标文件
                    objFileItem.fileType = OBJECT_FILE_FROM_STATIC_FILE;
                    NSRange objNameRange = bracketRange;
                    objNameRange.location ++;
                    objNameRange.length = objectFileName.length - objNameRange.location - 1;
                    objFileItem.name = [objectFileName substringWithRange: objNameRange];
                }else
                {
                    //用户自行创建的类
                    objFileItem.fileType = OBJECT_FILE_FROM_CUSTOM_CODE;
                    objFileItem.name     = objectFileName;
                }
                
            }else if ([pathStr hasPrefix: SYSTEM_LIB_PATH_PREFIX])
            {   //系统库目标文件
                objFileItem.fileType = OBJECT_FILE_FROM_SYSTEM_LIB;
                objFileItem.name     = objectFileName;
            }
            
            [tmpArray addObject: objFileItem];
        }
        
        // one loop end, start parsing next line log
        self.lastLineStr = [_linkMapfileReader readLine];
    }
    
    self.objectFileArray = [NSArray arrayWithArray: tmpArray];
    
}

/**
 *  解析段表log
 */
- (void)parseSectionTableLog
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity: 50];
    self.lastLineStr = [_linkMapfileReader readLine];
    
    while (![self isSectionStartFlag: _lastLineStr]) {
        NSArray *oneLineConponents = [_lastLineStr componentsSeparatedByString:@"\t"];
        NSString *sizeStr = oneLineConponents[1];
        NSString *segmentTypeStr = oneLineConponents[2];
        NSString *sectionNameStr = oneLineConponents[3];
        
        ExecutableCodeItem *codeItem = [[ExecutableCodeItem alloc] init];
        codeItem.size = strtoul([sizeStr UTF8String], 0, 16);
        NSUInteger lastIndex = [sectionNameStr length] - 1;//2 是制表符 \t 的两个字符位移
        codeItem.name = [sectionNameStr substringToIndex: lastIndex];
        
        if ([segmentTypeStr isEqualToString: SEGMENT_TYPE_CODE]) {
            codeItem.segmentType = CodeType_TEXT;
        }else if ([segmentTypeStr isEqualToString: SEGMENT_TYPE_DATA])
        {
            codeItem.segmentType = CodeType_DATA;
        }
        [tmpArray addObject: codeItem];
        
        //one loop end , start next circle
        self.lastLineStr = [_linkMapfileReader readLine];
    }
    
    self.executableCodeArray = [NSArray arrayWithArray: tmpArray];
    
}

/**
 *  解析符号表log
 */
- (void)parseSymbolTableLog
{
    self.lastLineStr = [_linkMapfileReader readLine];
    
    while (_lastLineStr  && ![self isSectionStartFlag: _lastLineStr]) {
        [self parseOneLineSymbolLog: _lastLineStr];
        self.lastLineStr = [self nextLineSymbolLog];
    }
}

/**
 * 确保读出的是一条完整的符号信息
 */
- (NSString *)nextLineSymbolLog
{
    NSString *symbolStr = [_linkMapfileReader readLine];
    NSString *nextLine = [_linkMapfileReader readLine];

    while (nextLine && ![nextLine hasPrefix:@"0x"]) {//下一条符号信息的固定头部
        
        symbolStr = [symbolStr stringByAppendingString: nextLine];
        nextLine = [_linkMapfileReader readLine];
    }
    
    if ([nextLine hasPrefix: @"0x"]) {
        //回退一行
        
        [_linkMapfileReader backwardOneLine];
    }
    
    return symbolStr;
}

- (NSString *)nextNoNilString
{
    NSString *symbolStr = [_linkMapfileReader readLine];
    while (!symbolStr) {
        symbolStr = [_linkMapfileReader readLine];
    }
    return symbolStr;
}

/**
 *  解析一行符号log
 *
 *  @param oneLineLog 一行符号log
 *
 *  @return 解析结果
 */
- (void)parseOneLineSymbolLog:(NSString *)oneLineLog
{
    //过滤非目标串
    NSString *filtreString = @"\t * \n * \x10\n * %@\n * \r\n";
    NSRange range = [filtreString rangeOfString: oneLineLog];
    if (range.location != NSNotFound) {
        
        return;
    }

    NSString *sizeStrPrefix = @"\t";
    range = [oneLineLog rangeOfString: sizeStrPrefix];
    NSUInteger sizeStrLoc = range.location + 1;
    NSUInteger sizeStrLen = 0;
    for (NSUInteger i = sizeStrLoc; i < [oneLineLog length]; ++i) {
        char curWord = [oneLineLog characterAtIndex: i];
        if (curWord == '\t') {
            sizeStrLen = i - sizeStrLoc;
        }
    }
    range = NSMakeRange(sizeStrLoc, sizeStrLen);
    NSString *sizeStr = [oneLineLog substringWithRange: range];
    //单个方法所占用的代码长度
    MethodFileItem *funcItem = [[MethodFileItem alloc] init];
    funcItem.size = strtoul([sizeStr UTF8String], 0, 16);
    
    //方法名称
    range = [oneLineLog rangeOfString: @"] "];
    NSUInteger funcNameLoc = range.location + 2;
    range.location = funcNameLoc;
    range.length = [oneLineLog length] - funcNameLoc - 1;
    NSString *funcStr = [oneLineLog substringWithRange: range];
    funcItem.name = funcStr;
    
    //所属的目标文件编号
    range = [oneLineLog rangeOfString: @"[" ];
    NSUInteger objectIndex_begin = range.location;
    range = [oneLineLog rangeOfString: @"]"];
    NSUInteger objectIndex_end = range.location;
    range.location = objectIndex_begin + 1;
    range.length = objectIndex_end - objectIndex_begin - 1;
    NSString *objectIndexStr = [oneLineLog substringWithRange: range];
    NSUInteger objectIndex = [objectIndexStr integerValue];
    
    //添加到所属的目标文件
    if (objectIndex < _objectFileArray.count) {
        ObjectFileItem *targetObjectFile = _objectFileArray[ objectIndex ];
        [targetObjectFile addMethodObject: funcItem];
    }
    
}


@end
