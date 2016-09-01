//
//  ViewController.m
//  CoreDataTest
//
//  Created by 邬志成 on 16/8/25.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "UserInfoModel.h"
#import <objc/runtime.h>
#import "Test+CoreDataProperties.h"

@interface ViewController ()

/* brief:应用代理 */
@property (nonatomic,strong) AppDelegate *app_delegate;

@end

@implementation ViewController{

    NSInteger curPage;

}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    curPage = 1;
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    [btn setTitle:@"添加数据" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    [self.view addSubview:btn];
    
    UIButton *delBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    [delBtn setTitle:@" 删除数据" forState:UIControlStateNormal];
    [delBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [delBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [delBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    delBtn.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    [self.view addSubview:delBtn];
    
    UIButton *resetPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    [resetPageBtn setTitle:@" 重置页码" forState:UIControlStateNormal];
    [resetPageBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [resetPageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [resetPageBtn addTarget:self action:@selector(resetPageAction) forControlEvents:UIControlEventTouchUpInside];
    resetPageBtn.center = CGPointMake(self.view.center.x, self.view.center.y);
    [self.view addSubview:resetPageBtn];

    
    UIButton *changeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    [changeBtn setTitle:@" 修改数据" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [changeBtn addTarget:self action:@selector(changeAction) forControlEvents:UIControlEventTouchUpInside];
    changeBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 50);
    [self.view addSubview:changeBtn];
    
    UIButton *getBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    [getBtn setTitle:@"获取数据" forState:UIControlStateNormal];
    [getBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [getBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [getBtn addTarget:self action:@selector(getAction) forControlEvents:UIControlEventTouchUpInside];
    getBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 100);
    [self.view addSubview:getBtn];
}


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


/* 重置页码 */
- (void)resetPageAction{

    curPage = 1;
    
}


- (AppDelegate *)app_delegate{

    if (_app_delegate) {
        return _app_delegate;
    }
    
    _app_delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    return _app_delegate;
}
@end
