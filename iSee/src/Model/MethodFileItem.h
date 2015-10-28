//
//  MethodFileItem.h
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/11.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  方法文件项目, 用于统计某一个具体的方法占用数据大小
 */
@interface MethodFileItem : NSObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) long int size;

@end
