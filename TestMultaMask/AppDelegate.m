//
//  AppDelegate.m
//  TestMultaMask
//
//  Created by 卢大维 on 15/3/25.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()<NSURLSessionDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%@", deviceToken);
}

- (void)           application:(UIApplication *)application
  didReceiveRemoteNotification:(NSDictionary *)userInfo
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Received remote notification with userInfo %@", userInfo);
    
    NSNumber *contentID = userInfo[@"content-id"];
#if 1
    NSString *downloadURLString = [NSString stringWithFormat:@"http://video.tianqi.cn/b4c3650fbdce4f23a4ce36a33d694a35.mp4"];
//    NSString *downloadURLString = [NSString stringWithFormat:@"http://video.tianqi.cn/fa07ee76c14846d4a300ceb7d75946ca.mp4"];
#else
    NSString *downloadURLString = [NSString stringWithFormat:@"http://scapi.weather.com.cn/product/cloudnew/20150318070000.PNG?date=201503181524&appid=6f688d&key=HucE45y1ZzVfF4m5z9Oy0GbFJDw="];
#endif
    NSURL* downloadURL = [NSURL URLWithString:downloadURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionDownloadTask *task = [[self backgroundURLSession] downloadTaskWithRequest:request];
    task.taskDescription = [NSString stringWithFormat:@"%@", [NSDate date]];
    [task resume];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    [self presentNotification:@"下载开始!"];

}



-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://apis.map.qq.com/ws/geocoder/v1/?location=39.984154,116.307490&key=ZU5BZ-4EDK4-NM3UL-XOTEH-Z5VTT-RGFL2&get_poi=1"];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            
                                            if (error) {
                                                completionHandler(UIBackgroundFetchResultFailed);
                                                return;
                                            }
                                            
                                            // 解析响应/数据以决定新内容是否可用
                                            BOOL hasNewData;
                                            if (hasNewData) {
                                                completionHandler(UIBackgroundFetchResultNewData);
                                            } else {
                                                completionHandler(UIBackgroundFetchResultNoData);
                                            }
                                            
                                            
                                        }];
    
    // 开始任务
    [task resume];
}

- (NSURLSession *)backgroundURLSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.weather.test2-backgroundTransferExample";
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return session;
}

#pragma Mark - NSURLSessionDownloadDelegate

- (void)         URLSession:(NSURLSession *)session
               downloadTask:(NSURLSessionDownloadTask *)downloadTask
  didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"downloadTask:%@ didFinishDownloadingToURL:%@", downloadTask.taskDescription, location);
    
    // 用 NSFileManager 将文件复制到应用的存储中
    // ...
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    NSString *tmp = [[[downloadTask originalRequest] URL] lastPathComponent];
    
    NSString *originalURL = [NSString stringWithFormat:@"%.f.%@", [[NSDate date] timeIntervalSince1970], tmp];//[[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:originalURL];
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&errorCopy];
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myNoti2" object:nil];
        
        double progress = (double)downloadTask.countOfBytesReceived / (double)downloadTask.countOfBytesExpectedToReceive;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myNoti1" object:nil userInfo:@{@"radio": @(progress)}];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self presentNotification:@"下载完成!"];
//        });
    } else {
        NSLog(@"复制文件发生错误: %@", [errorCopy localizedDescription]);
    }
}

-(void)presentNotification:(NSString *)body
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = body;//@"下载完成!";
    localNotification.alertAction = @"查看";
    //提示音
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //icon提示加1
//    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)  URLSession:(NSURLSession *)session
        downloadTask:(NSURLSessionDownloadTask *)downloadTask
   didResumeAtOffset:(int64_t)fileOffset
  expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)         URLSession:(NSURLSession *)session
               downloadTask:(NSURLSessionDownloadTask *)downloadTask
               didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten
  totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat radio = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"%f---%d, %d, %d, %@", radio, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, downloadTask.taskDescription);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"myNoti1" object:nil userInfo:@{@"radio": @(radio)}];
}



- (void)                  application:(UIApplication *)application
  handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // 你必须重新建立一个后台 seesiong 的参照
    // 否则 NSURLSessionDownloadDelegate 和 NSURLSessionDelegate 方法会因为
    // 没有 对 session 的 delegate 设定而不会被调用。参见上面的 backgroundURLSession
    NSURLSession *backgroundSession = [self backgroundURLSession];
    
    NSLog(@"Rejoining session with identifier %@ %@", identifier, backgroundSession);
    
    // 保存 completion handler 以在处理 session 事件后更新 UI
//    [self addCompletionHandler:completionHandler forSession:identifier];
    completionHandler(UIBackgroundFetchResultNewData);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"myNoti2" object:nil];
    [self presentNotification:@"下载完成!"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentNotification:@"下载完成!"];
//    });
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier) {
        // 调用在 -application:handleEventsForBackgroundURLSession: 中保存的 handler
//        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
