//
//  ObjectFileItem.h
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/11.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MethodFileItem.h"

/**
 *  目标文件的来源
 */
typedef enum{
    OBJECT_FILE_FROM_INVALID_VAL = 0x00000000,  //无效值
    OBJECT_FILE_FROM_CUSTOM_CODE = 0x00000001,  //自定义可见代码
    OBJECT_FILE_FROM_STATIC_FILE = 0x00000010,  //第三方静态库
    OBJECT_FILE_FROM_SYSTEM_LIB = 0x00000100    //系统标准库
} OBJECT_FILE_SRC_ENUM;

/**
 *  目标文件项目, 用于统计.o 文件
 */
@interface ObjectFileItem : NSObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) long int funcSize;

@property (nonatomic, assign) long int propertySize;

@property (nonatomic, assign) OBJECT_FILE_SRC_ENUM fileType;

-(long int)totalMethodsSize;

-(void)addMethodObject:(MethodFileItem *)methodObj;

@end
