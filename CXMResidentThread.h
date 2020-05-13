//
//  CXMResidentThread.h
//  Adas
//
//  Created by 陈小明 on 2019/5/8.
//  Copyright © 2019 bitauto. All rights reserved.
// 自封装的常驻线程

#import <Foundation/Foundation.h>

typedef void(^ResidentTask)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CXMResidentThread : NSObject

//最大任务加载数 默认 1
@property (nonatomic,assign) NSUInteger maxQueue;

/*
 * 运行常驻线程
 */
- (void)run;

/*
 * 停止线程
 */
- (void)stop;

/*
 * 添加任务 进入线程 串行执行
 */
- (void)addExecuteTask:(ResidentTask)task;
/*
 * 删除所有任务
 */
- (void)removeAllTask;

@end

NS_ASSUME_NONNULL_END
