//
//  Test+CoreDataProperties.h
//  CoreDataTest
//
//  Created by 邬志成 on 16/8/31.
//  Copyright © 2016年 邬志成. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Test.h"
#import "UserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
#warning 这里只是使用 Xcode 自动生成这个类,并不需要处理
@interface Test (CoreDataProperties)

@property (nullable, nonatomic, retain) UserInfoModel *userinfo;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSNumber *score;

@end

NS_ASSUME_NONNULL_END
