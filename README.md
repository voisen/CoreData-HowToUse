### Core data 数据库入门及提升 
	
	如果对你有帮助或者你很喜欢的话请star,感谢支持

----
这里主要是讲如何使用系统自带的 CoreData 类对数据持久化到本地的操作,对于初学者十分适合使用,作为作者的我,将所有必要的注释全部写的清楚明了,使得 ios 开发人员在参考此文档时既有 demo 又有解释,实现快速上手.

----



- 插入数据/增加数据

````objc

/* 增 */
- (void)addAction {
    
    Test *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Test" inManagedObjectContext:self.app_delegate.managedObjectContext];
    UserInfoModel *model = [[UserInfoModel alloc]init];{
        model.age = arc4random_uniform(100);
        model.sex = arc4random_uniform(2);
        model.address = @"江苏省南京市江宁区将军大道十字路口";
    }
    
    obj.score = @(arc4random_uniform(100));
    obj.username = @"将军大道";
    obj.userinfo = model;
    
    [self.app_delegate saveContext];    //! < 持久化到本地
    
}
````

- 删除数据

````objc
/* 删 */
- (void)deleteAction{
    
    NSFetchRequest *req = [[NSFetchRequest alloc]initWithEntityName:@"Test"];
    
    NSArray *objs = [self.app_delegate.managedObjectContext executeFetchRequest:req error:nil];
    
    if (objs.count == 0) {
        NSLog(@"删除失败  --> 无数据");
        return;
    }
    
    Test *obj = [objs objectAtIndex:arc4random_uniform((u_int32_t)objs.count)];
    
    [self.app_delegate.managedObjectContext deleteObject:obj];  //! < 删除对象
    
    NSLog(@"删除成功");
    
    [self.app_delegate saveContext];   //! < 持久化到本地
    

}

````

- 修改数据

````objc
/* 改 */
- (void)changeAction{

    NSFetchRequest *req = [[NSFetchRequest alloc]initWithEntityName:@"Test"];
    
    NSArray *objs = [self.app_delegate.managedObjectContext executeFetchRequest:req error:nil];
    
    if (objs.count == 0) {
        NSLog(@"修改失败 ---> 无数据");
        return;
    }
    
    Test *obj = [objs objectAtIndex:arc4random_uniform((u_int32_t)objs.count)];
    
    obj.username = @"修改数据";      //! < 拿到数据对象后直接赋值操作并保存即可
    UserInfoModel *mod = [obj.userinfo copy];
    mod.address = @"南京市鼓楼区鼓楼地铁站🚇";
    obj.userinfo = mod;
    NSLog(@"修改成功");
    
    [self.app_delegate saveContext];    //! < 持久化到本地
    

}
````
- 查找数据(可以条件查找)

````objc
/* 查 */
- (void)getAction{
#warning 对于模型中的数据, NSFetchRequest 并不能对模型中属性值实现过滤操作,但是可以对模型外的数据进行处理
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]; //! < 实现查找的数据降序排列(NO,YES 为升序)
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"score < %ld", 60];   //! < 将分数小于60的查找出来
    
    req.predicate = predicate;
    
    /*
    
    // 分页用到  查找的数量与偏移量
    req.fetchLimit = 5;    //! < 数量                                |      结论:无论查找的数量设置多少,NSFetchRequest
                           //                                       | --->   都会遍历所有数据,并且按照事先约定的条件进行
    req.fetchOffset = req.fetchLimit * (curPage - 1); //! < 偏移量   |        处理后输出
     
     
     NSLog(@"**********************第%ld页*************************",curPage);
    
     */
    req.sortDescriptors = @[desc];
    
    NSArray *array = [self.app_delegate.managedObjectContext executeFetchRequest:req error:nil];
    
#pragma 模型内的数据可以采用数组的条件过滤操作,然而当进行此步骤操作时,分页效果将完全乱了
    
    NSPredicate *array_predicate = [NSPredicate predicateWithFormat:@"userinfo.age < %ld",20];
    
    array = [array filteredArrayUsingPredicate:array_predicate];
    
    if (array.count == 0) {
        NSLog(@"**********************无数据*************************");
        return;
    }
    
    
    curPage ++;
    
    for (Test *obj in array) {
        UserInfoModel *model = obj.userinfo;
        NSLog(@"%@ | %02ld | %02ld | %@ | %@",obj.username,model.age,[obj.score integerValue],model.sex?@"男":@"女",model.address);
    }
    
}

````

----

### 数据持久的变量初始化
 - NSManagedObjectContext 初始化
 
````objc
 if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator]; //这里需要指定协作器,就是连接对象上下文和模型的桥梁 
    return _managedObjectContext;
     
````
 
 - NSManagedObjectModel 初始化
 
 ````objc
 if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"文件名" withExtension:@"momd"]; //这里的`文件名`就是在资源文件中生成的`***.xcdatamodeld `文件名,后缀在 url 中必须为 momd,(其实是个文件夹里面的文件,可以输出地址查看)
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]; //指定模型地址
    return _managedObjectModel;
 
 ````
 - NSPersistentStoreCoordinator 初始化
 
 ````objc
  if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
   NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"文件名.sqlite"]; //这里是指定数据库存储的地方和名字-->文件名
[_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil]; //添加数据库的路径
 return _persistentStoreCoordinator;
 
 ````
 
### (必须)如果使用了动态存储,则模型需要遵守/实现 NSCoding 协议

- 例如(实现部分)
````objc

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

````

### (可选)如果想通过 copy 来完整拷贝一个模型数据到一个新的模型,则模型需要遵守/实现 NSCopying 协议

- 例如(实现部分)
````objc
- (id)copyWithZone:(nullable NSZone *)zone{

    UserInfoModel *model = [[UserInfoModel allocWithZone:zone]init];

    model.address = self.address;
    
    model.sex = self.sex;
    
    model.age = self.age;
    
    return model;
}

````
