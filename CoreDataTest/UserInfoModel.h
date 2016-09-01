//
//  UserInfoModel.h
//  CoreDataTest
//
//  Created by 邬志成 on 16/8/25.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject<NSCoding/* 是为了可以直接使用`.`语法写入数据库 */,NSCopying/*是为了实现 copy 功能*/>

/* brief:年龄 */
@property (nonatomic,assign)  NSInteger age;

/* brief:性别 */
@property (nonatomic,assign)  BOOL sex;

/* brief:地址 */
@property (nonatomic,strong)  NSString *address;

@end
