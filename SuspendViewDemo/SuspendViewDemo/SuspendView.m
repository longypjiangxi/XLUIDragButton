//
//  SuspendView.m
//  DCGAMES
//
//  Created by LYP on 2022/8/10.
//

#import "SuspendView.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define ViewSize 50
#define KHeightFit(w)           (((w) / 667.0) * SCREEN_HEIGHT)

#define LRString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define DLog(...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];\
NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];\
printf("%s %s 第%d行:%s\n\n",[dateString UTF8String],[LRString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);}

@implementation SuspendView


- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.redColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = ViewSize/2;
        self.alpha = 0.5;
        
        //获取设备方向
        self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (self.orientation == UIInterfaceOrientationLandscapeRight){//横向home键在右侧，设备左转，刘海在左边
            self.frame = CGRectMake(SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize - 20, KHeightFit(80) + ViewSize/2, ViewSize, ViewSize);
        }else{
            self.frame = CGRectMake(SCREEN_WIDTH - ViewSize/2, KHeightFit(80) + ViewSize/2, ViewSize, ViewSize);
        }
        
        self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn.frame = CGRectMake(5, 5, 40, 40);
        self.btn.backgroundColor = UIColor.greenColor;
        self.btn.layer.cornerRadius = 20;
        [self.btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btn];
        //获取按钮与屏幕初始宽高比例
        [self changeCoordinateScale];
        //是否改变了悬浮窗初始位置
        isChangePosition = NO;
        
        //添加手势
        UIPanGestureRecognizer *panRcognize=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [panRcognize setMinimumNumberOfTouches:1];
        [panRcognize setEnabled:YES];
        [panRcognize delaysTouchesEnded];
        [panRcognize cancelsTouchesInView];
        [self addGestureRecognizer:panRcognize];
       
        //监听屏幕旋转
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientation)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)didChangeStatusBarOrientation {

    self.orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.imageView.frame = CGRectMake((SCREEN_WIDTH - 100)/2, (SCREEN_HEIGHT - 76)/2, 100, 76);
//    DLog(@"===%zd=====%zd",[[UIDevice currentDevice] orientation],[UIApplication sharedApplication].statusBarOrientation);
    //请注意，UIInterfaceOrientationAndScapeLeft等于UIDeviceOrientation AndScapeRight（反之亦然）。
    //这是因为向左旋转设备需要向右旋转内容。
    /**
     UIInterfaceOrientationUnknown            = UIDeviceOrientationUnknown,
     UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
     UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
     UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
     UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
     */
    
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
           // DLog(@"设备倒垂直，home在上")
            [self locationChange:@"Down"];
            break;
        case UIDeviceOrientationLandscapeLeft:{
          //  DLog(@"设备横屏，左转，home在右")
            [self locationChange:@"left"];
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
//            DLog(@"设备横屏，右转，home在左")
            [self locationChange:@"right"];
        }
            break;
        case UIDeviceOrientationPortrait:{
//            DLog(@"设备垂直，home在下");
            [self locationChange:@"Portrait"];
        }
            break;
        default:
            break;
    }
}
//根据屏幕宽高改变按钮位置比例
- (void)locationChange:(NSString *)message{
//    NSLog(@"changeHig == %f,changeWid == %f",changeHig,changeWid);
    if (SCREEN_HEIGHT > SCREEN_WIDTH) {
        //屏幕方向上
        if ([message isEqualToString:@"Portrait"]) {
            NSLog(@"安全区在上边");
            self.center = CGPointMake(changeWid * SCREEN_WIDTH, changeHig * SCREEN_HEIGHT);
        }else{//下
            NSLog(@"安全区在下边");
            self.center = CGPointMake(changeWid * SCREEN_WIDTH, changeHig * SCREEN_HEIGHT - [self vg_safeDistanceTop]);
        }
    }else{
        if ([message isEqualToString:@"left"]) {//左
            NSLog(@"安全区在左边");
            self.center = CGPointMake(changeWid * SCREEN_WIDTH + [self vg_safeDistanceTop] + ViewSize, changeHig * SCREEN_HEIGHT);
        }else{//右
            NSLog(@"安全区在右边");
            self.center = CGPointMake(changeWid * SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize, changeHig * SCREEN_HEIGHT);
        }
    }
//    NSLog(@"lastPoint == %@, self.center == %@",NSStringFromCGPoint(lastPoint),NSStringFromCGPoint(self.center));

    [self changeCoordinateScale];
    
}
//旋转屏幕后修改悬浮窗相对于屏幕的宽高比例以及坐标位置
- (void)changeCoordinateScale{
    changeHig = self.center.y/SCREEN_HEIGHT;
    changeWid = self.center.x/SCREEN_WIDTH;
    //判断设备旋转方向
    if (self.orientation == UIInterfaceOrientationLandscapeRight) {//横向home键在右侧，设备左转，刘海在左边，刘海在左边
        //判断悬浮窗坐标x在屏幕的左边还是右边
        if (self.center.x > SCREEN_WIDTH/2) {//大于中心x，在右边
            //修改悬浮窗的坐标在最右边
            self.center = CGPointMake(SCREEN_WIDTH, self.center.y);
        }else{
            //修改悬浮窗的坐标在最左边
            self.center = CGPointMake([self vg_safeDistanceTop] + ViewSize + 20, self.center.y);
        }
    }else if(self.orientation == UIInterfaceOrientationLandscapeLeft){//横向home键在左侧，设备右转，刘海在右边
        if (self.center.x > SCREEN_WIDTH/2) {//大于中心x，在右边
            //修改悬浮窗的坐标在最右边，留出顶部安全距离
            self.center = CGPointMake(SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize - 20, self.center.y);
        }else{
            //修改悬浮窗的坐标在最左边
            self.center = CGPointMake(0, self.center.y);
        }
    }else{
        //大于中心x，在右边
        if (self.center.x > SCREEN_WIDTH/2) {
            self.center = CGPointMake(SCREEN_WIDTH, self.center.y);
        }else{
            self.center = CGPointMake(0, self.center.y);
        }
    }
//    NSLog(@"changeHig == %f,changeWid == %f",changeHig,changeWid);
//    NSLog(@"设备宽度 == %f, 设备高度== %f, 按钮坐标==%@",SCREEN_WIDTH,SCREEN_HEIGHT,NSStringFromCGPoint(self.center));
}
- (void)showSuspendView{
    self.hidden = NO;
    NSLog(@"显示悬浮窗");
}
- (void)dismissSuspendView{
    self.hidden = YES;
    NSLog(@"隐藏悬浮窗");
}
/// 悬浮窗按钮点击放法
/// @param button 点击之后完全显示悬浮窗，改变按钮位置
- (void)btnClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspendViewButtonClick:)]) {
        [self.delegate suspendViewButtonClick:button];
    }
//    DLog(@"lastPoint == %@",NSStringFromCGPoint(lastPoint));
    //如果没有改变过位置，lastPoint初始值（0，0）
    //判断是否移动过悬浮窗
    if (!isChangePosition) {
        //悬浮窗初始位置在右上角，只有屏幕向右旋转，才需要留出iphone刘海的位置，设备左转刘海在左边，所以不需要做判断
        if (self.orientation == UIInterfaceOrientationLandscapeLeft) {//横向home键在左侧，设备右转，刘海在右边
            //修改点击后悬浮窗的位置，留出安全距离
            [UIView animateWithDuration:0.5 animations:^{
                self.center = CGPointMake(SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize - 20 - 20, self.center.y);
            }];
        }else{
            [UIView animateWithDuration:0.5 animations:^{
                self.center = CGPointMake(SCREEN_WIDTH - ViewSize, self.center.y);
            }];
        }
    }else{
//        判断最后的坐标是靠左还是靠右
        if (self.orientation == UIInterfaceOrientationLandscapeRight) {//横向home键在右侧，设备左转，刘海在左边
            if (self.center.x > SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(SCREEN_WIDTH - ViewSize, self.center.y);
                }];
            }else{
                //左转刘海在左边，留出安全距离
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake([self vg_safeDistanceTop] + ViewSize + 20 + 20, self.center.y);
                }];
            }
        }else if(self.orientation == UIInterfaceOrientationLandscapeLeft){//横向home键在左侧，设备右转，刘海在右边
            if (self.center.x > SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧，留出刘海安全距离
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize - 20 - 20, self.center.y);
                }];
            }else{//左侧显示
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(ViewSize, self.center.y);
                }];
            }
        }else{
            if (self.center.x < SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(ViewSize, self.center.y);
                }];
            }else{
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(SCREEN_WIDTH - ViewSize, self.center.y);
                }];
            }
        }
        
    }
    
    self.alpha = 1;
    //三秒后隐藏悬浮窗,贴边展示一半
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
}

- (void)timerAction{
    //隐藏悬浮球
    self.alpha = 0.5;
    //判断是否移动过悬浮窗
    if (!isChangePosition) {
        //悬浮窗初始位置在右上角，只有屏幕向右旋转，才需要留出iphone刘海的位置，设备左转刘海在左边，所以不需要做判断
        if (self.orientation == UIInterfaceOrientationLandscapeLeft) {//横向home键在左侧，设备右转，刘海在右边
            [UIView animateWithDuration:0.5 animations:^{
                self.center = CGPointMake(SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize - 20, self.center.y);
            }];
        }else{
            [UIView animateWithDuration:0.5 animations:^{
                self.center = CGPointMake(SCREEN_WIDTH, self.center.y);
            }];
        }
       
    }else{
        if (self.orientation == UIInterfaceOrientationLandscapeRight) {//横向home键在右侧，设备左转，刘海在左边
            if (self.center.x > SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(SCREEN_WIDTH, self.center.y);
                }];
            }else{
                //悬浮窗在屏幕左侧，留出刘海安全距离
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake([self vg_safeDistanceTop] + ViewSize + 20, self.center.y);
                }];
            }
        }else if(self.orientation == UIInterfaceOrientationLandscapeLeft){//横向home键在左侧，设备右转，刘海在右边
            if (self.center.x > SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧
                //悬浮窗在屏幕左侧，留出刘海安全距离
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize - 20, self.center.y);
                }];
            }else{
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(0, self.center.y);
                }];
            }
            
        }else{
            if (self.center.x > SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(SCREEN_WIDTH, self.center.y);
                }];
            }else{
                [UIView animateWithDuration:0.5 animations:^{
                    self.center = CGPointMake(0, self.center.y);
                }];
            }
            
        }
    }
    //销毁定时器
    [self.timer invalidate];
    self.timer = nil;
}


/// pan手势
/// @param recognizer recognizer description
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    //移动状态
    UIGestureRecognizerState recState =  recognizer.state;
    isChangePosition = YES;
    
    switch (recState) {
        case UIGestureRecognizerStateBegan:
            self.alpha = 1;
            self.imageView.hidden = NO;
            break;
        case UIGestureRecognizerStateChanged://移动中
        {
            self.alpha = 1;
            CGPoint translation = [recognizer translationInView:self];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
            
            CGRect rect = [self convertRect:self.frame toView:self];
            if (CGRectIntersectsRect(self.imageView.frame, rect)) {//在范围内
                self.imageView.backgroundColor = UIColor.redColor;
            }else{
                self.imageView.backgroundColor = UIColor.blueColor;
            }
        }
            break;
        case UIGestureRecognizerStateEnded://移动结束
        {
            self.alpha = 0.5;
            CGPoint stopPoint = CGPointMake(0, SCREEN_HEIGHT / 2);
            //判断按钮贴靠在屏幕的左边还是右边
            if (recognizer.view.center.x < SCREEN_WIDTH / 2) {
                stopPoint = CGPointMake(ViewSize/2, recognizer.view.center.y);
            }else{
                //贴靠在右边
                stopPoint = CGPointMake(SCREEN_WIDTH - ViewSize/2,recognizer.view.center.y);
            }
            DLog(@"stopPoint == %@",NSStringFromCGPoint(stopPoint));
            
            if (stopPoint.y - ViewSize/2 <= 0) {
                DLog(@"上");
                //加上电池栏的高度
                if (stopPoint.x - ViewSize/2 <= SCREEN_WIDTH/2) {
                    stopPoint = CGPointMake(0, stopPoint.y + [self vg_safeDistanceTop] + ViewSize);
                    DLog(@"左上");
                }else{
                    DLog(@"右上");
                    stopPoint = CGPointMake(SCREEN_WIDTH, stopPoint.y + [self vg_safeDistanceTop] + ViewSize);
                }
            }
            //如果按钮超出屏幕边缘
            if (stopPoint.y + ViewSize + 20 >= SCREEN_HEIGHT) {
                DLog(@"下");
                //减去底部状态栏的高度
                if (stopPoint.x - ViewSize/2 <= SCREEN_WIDTH/2) {
                    DLog(@"左下");
                    stopPoint = CGPointMake(0, stopPoint.y - [self vg_safeDistanceBottom] - ViewSize/2);
                }else{
                    DLog(@"右下");
                    stopPoint = CGPointMake(SCREEN_WIDTH, stopPoint.y - [self vg_safeDistanceBottom] - ViewSize/2);
                }
//                DLog(@"超出屏幕下方");
            }
            
            if (stopPoint.x - ViewSize/2 <= 0) {
                DLog(@"左");
//                stopPoint = CGPointMake(ViewSize/2, stopPoint.y);
                //缩进去一半
                stopPoint = CGPointMake(0, stopPoint.y);
            }
            if (stopPoint.x + ViewSize/2 >= SCREEN_WIDTH) {
                DLog(@"右");
//                stopPoint = CGPointMake(SCREEN_WIDTH - ViewSize/2, stopPoint.y);
                stopPoint = CGPointMake(SCREEN_WIDTH, stopPoint.y);
            }
            
            //保存最后的位置
            lastPoint = stopPoint;
           
            //隐藏悬浮球
            CGRect rect = [self convertRect:self.frame toView:self];
            if (CGRectIntersectsRect(self.imageView.frame, rect)) {//在范围内
                DLog(@"悬浮窗在中心imageview内，提示是否隐藏悬浮窗");
//                [self showAlertView];
                [self.delegate showHideAlertView];
            }
//            NSLog(@"self.orientation == %ld",(long)self.orientation);
            if (self.orientation == UIInterfaceOrientationLandscapeRight) {//横向home键在右侧，设备左转，刘海在左边
                if (stopPoint.x > SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧
                    [UIView animateWithDuration:0.5 animations:^{
                        recognizer.view.center = CGPointMake(SCREEN_WIDTH, stopPoint.y);
                    }];
                }else{
                    //悬浮窗在屏幕左侧，留出刘海安全距离
                    [UIView animateWithDuration:0.5 animations:^{
                        recognizer.view.center = CGPointMake([self vg_safeDistanceTop] + ViewSize + 20, stopPoint.y);
                    }];
                }
            }else if(self.orientation == UIInterfaceOrientationLandscapeLeft){//横向home键在左侧，设备右转，刘海在右边
                if (stopPoint.x > SCREEN_WIDTH/2) {//悬浮窗在屏幕右侧
                    //悬浮窗在屏幕左侧，留出刘海安全距离
                    [UIView animateWithDuration:0.5 animations:^{
                        recognizer.view.center = CGPointMake(SCREEN_WIDTH - [self vg_safeDistanceTop] - ViewSize - 20, stopPoint.y);
                    }];
                }else{
                    [UIView animateWithDuration:0.5 animations:^{
                        recognizer.view.center = CGPointMake(0, stopPoint.y);
                    }];
                }
                
            }else{
                [UIView animateWithDuration:0.5 animations:^{
                    recognizer.view.center = stopPoint;
                }];
            }
            [self changeCoordinateScale];
        
            self.imageView.hidden = YES;
            
        }
            break;
            
        default:
            break;
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}

//获取头部安全区高度
- (CGFloat)vg_safeDistanceTop {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.top;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.top;
    }
    return 0;
}

//获取设备底部安全区高度
- (CGFloat)vg_safeDistanceBottom {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.bottom;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.bottom;
    }
    return 0;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 50)/2, (SCREEN_HEIGHT - 50)/2, 50, 50)];
        _imageView.backgroundColor = UIColor.blueColor;
        _imageView.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:_imageView];
    }
    return _imageView;
}

@end
