//
//  DDFileReader.m
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/26.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import "DDFileReader.h"
#import "NSData+DDAdditions.h"

@implementation DDFileReader

@synthesize lineDelimiter, chunkSize;

- (id) initWithFilePath:(NSString *)aPath {
    if (self = [super init]) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPath];
        if (fileHandle == nil) {
            return nil;
        }
        
        lineDelimiter = @"\n";
        currentOffset = 0ULL; // ???
        chunkSize = 128;
        [fileHandle seekToEndOfFile];
        totalFileLength = [fileHandle offsetInFile];
        //we don't need to seek back, since readLine will do that.
    }
    return self;
}

- (void) dealloc {
    [fileHandle closeFile];
    currentOffset = 0ULL;
    
}

- (NSString *) readLine {
    if (currentOffset >= totalFileLength) { return nil; }
    
    NSData * newLineData = [lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle seekToFileOffset:currentOffset];
    NSMutableData * currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
    
    @autoreleasepool {
        
        while (shouldReadMore) {
            if (currentOffset >= totalFileLength) { break; }
            NSData * chunk = [fileHandle readDataOfLength:chunkSize];
            NSRange newLineRange = [chunk rangeOfData_dd:newLineData];
            if (newLineRange.location != NSNotFound) {
                
                //include the length so we can include the delimiter in the string
                chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location+[newLineData length])];
                shouldReadMore = NO;
            }
            [currentData appendData:chunk];
            currentOffset += [chunk length];
        }
    }
    
    NSString * line = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    return line;
}

- (NSString *) readTrimmedLine {
    return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (double) readedFileSizeRatio
{
    
    return (double)currentOffset / totalFileLength;
}

- (void) backwardOneLine
{
    unsigned long long tempOffset = currentOffset - lineDelimiter.length; //jump over last delimiter string
    NSUInteger tempChunkSize = chunkSize;
    if (tempOffset < tempChunkSize) {
        //have moved to file's head
        tempOffset = 0;
    }else{
        tempOffset -= tempChunkSize;
    }
    NSData * newLineData = [lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    @autoreleasepool {
        while (1) {
            [fileHandle seekToFileOffset: tempOffset];
            
            NSData *preChunk =  [fileHandle readDataOfLength: tempChunkSize];
            NSRange preDelimiterRange = {NSNotFound,0};
            
            preDelimiterRange = [preChunk rangeOfLastData_dd: newLineData];
            if (preDelimiterRange.location != NSNotFound) {
                tempOffset += (preDelimiterRange.location + 1);
                //backward a line successfully.
                break;
            }
            if (tempOffset == 0) { // have moved to file's header
                break;
            }
            if (tempOffset < tempChunkSize) {
                tempOffset = 0;
                tempChunkSize = tempOffset;
            }else
            {
                tempOffset -= tempChunkSize;
            }
        }
    }
    
    currentOffset = tempOffset;
}

#if NS_BLOCKS_AVAILABLE
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
    NSString * line = nil;
    BOOL stop = NO;
    while (stop == NO && (line = [self readLine])) {
        block(line, &stop);
    }
}
#endif

@end
