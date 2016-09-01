//
//  UserInfoModel.m
//  CoreDataTest
//
//  Created by 邬志成 on 16/8/25.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel


#pragma mark - NSCoding 协议实现

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.age] forKey:@"age"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.sex] forKey:@"sex"];
    [aCoder encodeObject:self.address forKey:@"address"];

}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{

    self = [super init];
    
    if (self) {
        self.age = [[aDecoder decodeObjectForKey:@"age"] integerValue];
        self.sex = [[aDecoder decodeObjectForKey:@"sex"] boolValue];
        self.address =  [aDecoder decodeObjectForKey:@"address"];
    }
    
    return self;
}

#pragma mark - NSCopying 协议实现

- (id)copyWithZone:(nullable NSZone *)zone{

    UserInfoModel *model = [[UserInfoModel allocWithZone:zone]init];

    model.address = self.address;
    
    model.sex = self.sex;
    
    model.age = self.age;
    
    return model;
}

@end
