# CXMRunloopClass
利用Runloop 开辟常驻线程
使用方式：
```
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
```
1.实例化线程对象并运行`run`：
```  
self.myThread = [[CXMResidentThread alloc] init];
    [self.myThread run];
```
2.把耗时操作传给Block
```
 [self.myThread addExecuteTask:^{
//        [NSThread sleepForTimeInterval:3];        
                }];
```
3.在想结束常驻线程时 调用`stop`
```
-(void)dealloc{
    //终止线程
    [self.myThread stop];   
}
```
> 注意这个常驻线程只能处理 串行任务。
