//
//  ExecutableCodeItem.h
//  iSee
//
//  Created by Yangtsing.Zhang on 15/10/22.
//  Copyright © 2015年 ___Baidu Inc.___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEGMENT_TYPE_CODE @"__TEXT"
#define SEGMENT_TYPE_DATA @"__DATA"

/**
 *  可执行文件的段类型
 */
typedef enum{
    CodeType_TEXT,  //代码段
    CodeType_DATA   //数据段
} GSExecutableCodeType;

@interface ExecutableCodeItem : NSObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) GSExecutableCodeType segmentType;

@property (nonatomic, assign) long int size;

@end
