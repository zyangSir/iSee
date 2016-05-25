//
//  DDFileReader.h
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/26.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//  该类原作者为: http://stackoverflow.com/users/115730/dave-delong
//

#import <Foundation/Foundation.h>

@interface DDFileReader : NSObject
{
    NSString * filePath;
    
    NSFileHandle * fileHandle;
    unsigned long long currentOffset;
    unsigned long long totalFileLength;
    
    NSString * lineDelimiter;
    NSUInteger chunkSize;
}

@property (nonatomic, copy) NSString * lineDelimiter;
@property (nonatomic) NSUInteger chunkSize;

- (id) initWithFilePath:(NSString *)aPath;

- (NSString *) readLine;
- (NSString *) readTrimmedLine;
// 已读文件长度 与 文件总长度 比值, 范围0~1间
- (double ) readedFileSizeRatio;

- (void) backwardOneLine;

#if NS_BLOCKS_AVAILABLE
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL *))block;
#endif

@end
