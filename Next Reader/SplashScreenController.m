#import "SplashScreenController.h"

@interface SplashScreenController ()

@property (nonatomic, strong) UIView *gradientView;

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UILabel *sloganLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, copy) void(^completionBlock)(void);

@end

@implementation SplashScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.duration = 2.4;
    [self setupUI];
    [self startAnimation];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 渐变背景视图
    self.gradientView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.gradientView];
    
    // 添加渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.5 blue:0.9 alpha:1.0].CGColor
    ];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    [self.gradientView.layer insertSublayer:gradientLayer atIndex:0];
    
    // Logo 图标（使用系统图标作为示例，你可以替换为自己的图标）
    self.logoImageView = [[UIImageView alloc] init];
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.logoImageView.backgroundColor = [UIColor whiteColor];
    self.logoImageView.layer.cornerRadius = 30;
    self.logoImageView.layer.masksToBounds = YES;
    
    // 如果没有自定义图标，使用默认图标
    UIImage *logoImage = [UIImage imageNamed:@"AppIcon"];
    if (!logoImage) {
        // 创建一个默认的图标
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, 0);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 120, 120) cornerRadius:30];
        [[UIColor whiteColor] setFill];
        [path fill];
        
        // 绘制一个简单的书本图标
        [[UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0] setFill];
        UIBezierPath *bookPath = [UIBezierPath bezierPathWithRect:CGRectMake(35, 30, 50, 60)];
        [bookPath fill];
        
        UIImage *defaultLogo = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        logoImage = defaultLogo;
    }
    self.logoImageView.image = logoImage;
    [self.view addSubview:self.logoImageView];
    
    // App 名称
    self.appNameLabel = [[UILabel alloc] init];
    self.appNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.appNameLabel.text = @"Next Reader";
    self.appNameLabel.font = [UIFont boldSystemFontOfSize:28];
    self.appNameLabel.textColor = [UIColor whiteColor];
    self.appNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.appNameLabel];
    
    // 标语
    self.sloganLabel = [[UILabel alloc] init];
    self.sloganLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sloganLabel.text = @"阅读，让思想远行";
    self.sloganLabel.font = [UIFont systemFontOfSize:14];
    self.sloganLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.sloganLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.sloganLabel];
    
    // 加载指示器
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.color = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.logoImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.logoImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-60],
        [self.logoImageView.widthAnchor constraintEqualToConstant:100],
        [self.logoImageView.heightAnchor constraintEqualToConstant:100],
        
        [self.appNameLabel.topAnchor constraintEqualToAnchor:self.logoImageView.bottomAnchor constant:20],
        [self.appNameLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.appNameLabel.leftAnchor constraintGreaterThanOrEqualToAnchor:self.view.leftAnchor constant:20],
        [self.appNameLabel.rightAnchor constraintLessThanOrEqualToAnchor:self.view.rightAnchor constant:-20],
        
        [self.sloganLabel.topAnchor constraintEqualToAnchor:self.appNameLabel.bottomAnchor constant:8],
        [self.sloganLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.sloganLabel.leftAnchor constraintGreaterThanOrEqualToAnchor:self.view.leftAnchor constant:20],
        [self.sloganLabel.rightAnchor constraintLessThanOrEqualToAnchor:self.view.rightAnchor constant:-20],
        
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-50],
        [self.activityIndicator.widthAnchor constraintEqualToConstant:37],
        [self.activityIndicator.heightAnchor constraintEqualToConstant:37]
    ]];
}

- (void)startAnimation {
    // 初始状态：logo 缩小且透明
    self.logoImageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.logoImageView.alpha = 0;
    self.appNameLabel.alpha = 0;
    self.sloganLabel.alpha = 0;
    
    // 弹性动画：logo 弹出效果
    [UIView animateWithDuration:0.6 delay:0.2 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.logoImageView.transform = CGAffineTransformIdentity;
        self.logoImageView.alpha = 1;
    } completion:nil];
    
    // 文字淡入
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.appNameLabel.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.sloganLabel.alpha = 1;
    } completion:nil];
    
    // 启动加载指示器
    [self.activityIndicator startAnimating];
    
    // 3秒后执行完成回调
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissWithCompletion];
    });
}

- (void)dismissWithCompletion {
    [self.activityIndicator stopAnimating];
    
    // 淡出动画
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.completionBlock) {
            self.completionBlock();
        }
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)showInWindow:(UIWindow *)window completion:(void(^)(void))completion {
    self.completionBlock = completion;
    
    // 添加开屏视图到 window
    self.view.frame = window.bounds;
    self.view.alpha = 1;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
}

@end
