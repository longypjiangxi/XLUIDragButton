//
//  ViewController.m
//  
//
//  Created by LYP on 2022/8/4.
//

#import "ViewController.h"
#import "SuspendView.h"
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<SuspendViewDelegate>

@property (nonatomic, retain) UIButton *loginBtn;/**<#name#>*/
@property (nonatomic, retain) UIButton *signOutBtn;/**<#name#>*/
@property (nonatomic, retain) UIButton *menuBtn;/**<#name#>*/
@property (nonatomic, retain) SuspendView *suspendView;/**<#name#>*/
@property (nonatomic, strong) NSTimer* timer;/**<#name#>*/
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.menuBtn];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:false block:^(NSTimer * _Nonnull timer) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.suspendView];
        [self->_timer invalidate];
        self->_timer = nil;
    }];
    
    [self configSYSDKNotification];
   
}

- (void)uploadViewFrame{
    self.menuBtn.frame = CGRectMake((SCREEN_WIDTH - 150)/2, 100, 150, 80);
}

#pragma mark ========================= SuspendViewDelegate =========================
- (void)suspendViewButtonClick:(nonnull UIButton *)sender {
    NSLog(@"按钮点击事件");
}

- (void)showHideAlertView{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否隐藏悬浮窗" preferredStyle:UIAlertControllerStyleAlert];
    // 增加取消按钮；
    [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"不隐藏");
    }]];
    // 增加确定按钮；
    [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.suspendView dismissSuspendView];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark ========================= 通知 =========================
- (void)configSYSDKNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}


- (void)didChangeStatusBarOrientation {
    /**
     UIDeviceOrientationUnknown,
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
     UIDeviceOrientationFaceUp,              // Device oriented flat, face up
     UIDeviceOrientationFaceDown             // Device oriented flat, face down
     */
    switch ([UIDevice currentDevice].orientation)
    {
        case UIDeviceOrientationPortraitUpsideDown:
//            NSLog(@"faceBar在下面");
            break;
        case UIDeviceOrientationLandscapeLeft:
//            NSLog(@"faceBar在左边");
            break;
        case UIDeviceOrientationLandscapeRight:
//            NSLog(@"faceBar在右边");
            break;
        case UIDeviceOrientationPortrait:
//            NSLog(@"faceBar在上边");
            break;
        default: // as UIInterfaceOrientationPortrait
//                NSLog(@"faceBar在上边");
            break;
    }

    [self uploadViewFrame];
}

#pragma mark ========================= Click =========================

- (void)menuBtnClick:(UIButton *)button{
    [self.suspendView showSuspendView];
}

#pragma mark ========================= 懒加载 =========================

- (SuspendView *)suspendView {
    if (!_suspendView) {
        _suspendView = [[SuspendView alloc] init];
        _suspendView.delegate = self;
    }
    return _suspendView;
}

- (UIButton *)menuBtn{
    if(!_menuBtn){
        _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuBtn.frame = CGRectMake((SCREEN_WIDTH - 150)/2, 100, 150, 80);
        _menuBtn.layer.cornerRadius = 40;
        [_menuBtn setBackgroundColor: UIColor.whiteColor];
        [_menuBtn setTitle:@"显示悬浮窗" forState:UIControlStateNormal];
        [_menuBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuBtn;
}

@end
