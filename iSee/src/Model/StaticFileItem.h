//
//  StaticFileItem.h
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/11.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  静态库类，用于统计 .a 文件
 */
@interface StaticFileItem : NSObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) long int size;

@end
