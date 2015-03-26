//
//  ViewController.m
//  TestMultaMask
//
//  Created by 卢大维 on 15/3/25.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic,strong) AVPlayer *player;

@property (nonatomic,weak) IBOutlet UILabel *lbl1,*lbl2,*lbl3;
@property (nonatomic,weak) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti1:) name:@"myNoti1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti2) name:@"myNoti2" object:nil];
}

-(void)noti1:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lbl1.text = [NSString stringWithFormat:@"%.f%%", [[noti.userInfo objectForKey:@"radio"] floatValue]*100];
    });
}

-(void)noti2
{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
//    NSURL *documentsDirectory = [URLs objectAtIndex:0];
//    NSString *originalURL = @"test.mp4";//[[downloadTask originalRequest] URL];
//    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:originalURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lbl2.text = @"complited";
        
        //播放音乐
//        self.player = [AVPlayer playerWithURL:destinationURL];
//        [self.player play];
    });
}

-(IBAction)clickButton:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
//    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    NSString *_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *string = [[fileManager subpathsAtPath:_path] description];
    self.lbl3.text = string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
