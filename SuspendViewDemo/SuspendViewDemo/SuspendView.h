//
//  SuspendView.h
//  
//
//  Created by LYP on 2022/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SuspendViewDelegate <NSObject>
//点击事件
- (void)suspendViewButtonClick:(UIButton*)sender;
//显示是否隐藏提示框
- (void)showHideAlertView;
@end
@interface SuspendView : UIView
{
    CGPoint lastPoint;/**存储悬浮球最后的移动完位置*/
    BOOL isChangePosition;/**悬浮球是否改变了位置*/
    CGFloat changeHig;//按钮高度位置比例
    CGFloat changeWid;//按钮宽度位置比例

}
@property (nonatomic, retain) UIButton *btn;/**<#name#>*/
@property (nonatomic, strong) NSTimer *_Nullable timer;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, weak) id<SuspendViewDelegate> delegate;
//隐藏&显示
- (void)showSuspendView;
- (void)dismissSuspendView;
@end

NS_ASSUME_NONNULL_END
