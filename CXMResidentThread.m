//
//  CXMResidentThread.m
//  Adas
//
//  Created by 陈小明 on 2019/5/8.
//  Copyright © 2019 bitauto. All rights reserved.
//

#import "CXMResidentThread.h"
// 此次线程主要是为了看其是否被释放
@interface CXMThread : NSThread

@end

@implementation CXMThread

- (void)dealloc{
    
    NSLog(@"%s",__func__);
}

@end


@interface CXMResidentThread()

@property(nonatomic,strong)CXMThread *myThread;

@property(nonatomic,assign) BOOL stopped;
//任务数组
@property(nonatomic,strong) NSMutableArray *taskArray;


@end

@implementation CXMResidentThread

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.taskArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.maxQueue = 10;
        self.stopped = NO;
        __weak typeof(self) weakSelf = self;//防止循环引用
        
        if (@available(iOS 10.0, *)) {//iOS 10 以后
            
            self.myThread = [[CXMThread alloc] initWithBlock:^{
                
                NSLog(@"Thread  begin------%@",[NSThread currentThread]);
                
                //为runloop 添加source、或者 timer、或者 observer，否则runloop 回自己退出
                [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSRunLoopCommonModes];
                
                while (weakSelf&&!weakSelf.stopped) {
                    //启动 runloop
                    [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];

                }
                
                NSLog(@"Thread end------");
            }];
            
        } else {// ios 10 以前的 执行方法
            // C语言方式创建
            self.myThread = [[CXMThread alloc] initWithBlock:^{
               
                CFRunLoopSourceContext context = {0};//初始化 0
                
                CFRunLoopSourceRef runloopSourceRef = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, &context);
                
                CFRunLoopAddSource(CFRunLoopGetCurrent(),runloopSourceRef, kCFRunLoopDefaultMode);
                
                //启动runloop,第三个参数设置为 NO，则不需要 while 循环,第二个参数过期时间 写一个超大数。
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1000000000, NO);
                
            }];

        }
        
    }
    return self;
}

#pragma mark - 公共方法

- (void)run{
    
    if(self.myThread == nil) return;
    
    [self.myThread start];
    
}
//在 新线程执行任务
-(void)addExecuteTask:(ResidentTask)task{
    
    if(self.myThread == nil|| !task) return;
    
    [self.taskArray addObject:task];
    
    NSLog(@"taskArray==%@",self.taskArray);
    if(self.taskArray.count > self.maxQueue){
        
        [self.taskArray removeObjectAtIndex:0];
    }
    //object __addExecuteTask方法要 接受传递的参数
    [self performSelector:@selector(__addExecuteTask:) onThread:self.myThread withObject:self.taskArray waitUntilDone:NO];
    
}

- (void)stop{
    
    if(self.myThread == nil) return;
    //waitUntilDone:YES YES：是否等 @selector 方法执行完成后继续下面的方法，NO：不需要等执行完成
    [self performSelector:@selector(__stop) onThread:self.myThread withObject:nil waitUntilDone:YES];
}

- (void)removeAllTask{
    
    [self.taskArray removeAllObjects];
    
}
#pragma mark - 私有方法

- (void)__stop{
    
    self.stopped = YES; //停止 runloop
    // 停止当前线程，如果是在主线程调用 就会停止主线程
    
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.myThread = nil;
    
}

- (void)__addExecuteTask:(NSMutableArray*)taskArr{
    
    NSLog(@"taskArr==%@",taskArr);
    
    if(taskArr.count == 0) return;
    
  //  while (self.taskArray.count) {
        
        //取出任务
        ResidentTask  unit = self.taskArray.firstObject;
        
        //执行任务
        unit();
        
        //删除任务
        [self.taskArray removeObjectAtIndex:0];
  //  }
    
    NSLog(@"thread == %@",[NSThread currentThread]);
    
 
    
}

- (void)dealloc{
    
    NSLog(@"%s",__func__);
    
    [self stop];
    
}


















@end
