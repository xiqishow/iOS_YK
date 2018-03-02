//
//  YKLoginVC.m
//  YK
//
//  Created by LXL on 2017/11/24.
//  Copyright © 2017年 YK. All rights reserved.
//

#import "YKLoginVC.h"
#import "WXApi.h"

#import "LLGifImageView.h"
#import "LLGifView.h"
#import "YKChangePhoneVC.h"


@interface YKLoginVC ()<UITextFieldDelegate>{
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h1;//44
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h2;//66
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h3;//60
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h4;//64
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h5;//130
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h6;//130
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h7;//40
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *w1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *w2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h8;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h9;

@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UITextField *vetifyText;
@property (weak, nonatomic) IBOutlet UIButton *getVetifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *QQLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *WXLoginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (nonatomic, strong) LLGifView *gifView;
@property (nonatomic, strong) LLGifImageView *gifImageView;


@end
NSInteger timeNum;
@implementation YKLoginVC

- (void)removeGif {
    if (_gifView) {
        [_gifView removeFromSuperview];
        _gifView = nil;
    }
    if (_gifImageView) {
        [_gifImageView removeFromSuperview];
        _gifImageView = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //加载本地gif图片
    NSData *localData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s" ofType:@"gif"]];
    _gifView = [[LLGifView alloc] initWithFrame:CGRectMake(0, 0, WIDHT, HEIGHT) data:localData];
//    [self.view addSubview:_gifView];
//    [self.view sendSubviewToBack:_gifView];
    _gifView.alpha = 0.5;
    [_gifView startGif];

    //新UI隐藏logo
    [_logo setHighlighted:YES];
    
    [_QQLoginBtn setHidden:YES];
    [_WXLoginBtn setHidden:YES];
    
    if ([WXApi isWXAppInstalled]) {
        [_WXLoginBtn setHidden:NO];
        if (![TencentOAuth iphoneQQInstalled]) {
            [_QQLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.mas_centerX);
            }];
        }
    }
    if ([TencentOAuth iphoneQQInstalled]) {
        [_QQLoginBtn setHidden:NO];
        if (![WXApi isWXAppInstalled]) {
            [_WXLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.mas_centerX);
            }];
        }
    }
  
    
    [self setAutoLayoutMargin];
    self.phoneText.keyboardType = UIKeyboardTypeNumberPad;
    self.vetifyText.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneText.inputAccessoryView = [self addToolbar];
    self.vetifyText.inputAccessoryView = [self addToolbar];
    [self.vetifyText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.getVetifyBtn.userInteractionEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatDidLoginNotification:) name:@"wechatDidLoginNotification" object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TencentDidLoginNotification:) name:@"TencentDidLoginNotification" object:nil];
}

//接收qq登录成功的通知
- (void)TencentDidLoginNotification:(NSNotification *)notify{
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:notify.userInfo];
    [[YKUserManager sharedManager]loginSuccessByTencentDic:dic[@"code"] OnResponse:^(NSDictionary *dic) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([[YKUserManager sharedManager].user.phone isEqual:[NSNull null]]) {
                YKChangePhoneVC *changePhone = [YKChangePhoneVC new];
                changePhone.isFromThirdLogin = YES;
                changePhone.hidesBottomBarWhenPushed = YES;
                [[self getCurrentVC].navigationController pushViewController:changePhone animated:YES];
            }
        }];
    }];
}

//接收微信登录的通知
- (void)wechatDidLoginNotification:(NSNotification *)notify{
    NSDictionary *dict = [notify userInfo];
    [[YKUserManager sharedManager]getWechatAccessTokenWithCode:dict[@"code"] OnResponse:^(NSDictionary *dic) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([[YKUserManager sharedManager].user.phone isEqual:[NSNull null]] || [YKUserManager sharedManager].user.phone.length == 0) {
                YKChangePhoneVC *changePhone = [YKChangePhoneVC new];
                changePhone.isFromThirdLogin = YES;
                changePhone.hidesBottomBarWhenPushed = YES;
                [[self getCurrentVC].navigationController pushViewController:changePhone animated:YES];
            }
        }];

    }];
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    if ([window subviews].count>0) {
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]]){
            result = nextResponder;
        }
        else{
            result = window.rootViewController;
        }
    }
    else{
        result = window.rootViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [((UITabBarController*)result) selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [((UINavigationController*)result) visibleViewController];
    }
    
    return result;
}

- (void) textFieldDidChange:(id) sender {
    if (self.phoneText.text.length>10) {
        [self.getVetifyBtn setTitleColor:mainColor forState:UIControlStateNormal];
        self.getVetifyBtn.userInteractionEnabled = YES;
    }else {
        self.getVetifyBtn.userInteractionEnabled = NO;
       [self.getVetifyBtn setTitleColor:[UIColor colorWithHexString:@"afafaf"] forState:UIControlStateNormal];
    }
    if (self.phoneText.text.length>10&&self.vetifyText.text.length>0) {
        self.loginBtn.backgroundColor = mainColor;
        [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else {
        self.loginBtn.backgroundColor = [UIColor colorWithHexString:@"f8f8f8"];
        [self.loginBtn setTitleColor:[UIColor colorWithHexString:@"afafaf"] forState:UIControlStateNormal];
    }
}
- (void)setAutoLayoutMargin{
    CGFloat scale = WIDHT/414;
    self.h1.constant = 44*scale;
    self.h2.constant = 66*scale;
    self.h3.constant = 72*scale;
    self.h4.constant = 66*scale;
    self.h5.constant = 130*scale;
    self.h6.constant = 130*scale;
    self.h7.constant = 44*scale;
    self.h8.constant = 55*scale;
    self.h9.constant = 55*scale;
    self.w1.constant = self.w2.constant = 60*scale;
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/2;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.vetifyText resignFirstResponder];
    [self.phoneText resignFirstResponder];
 }

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDone{
    [self.vetifyText resignFirstResponder];
    [self.phoneText resignFirstResponder];
}
- (void)cancel{
    [self.vetifyText resignFirstResponder];
    [self.phoneText resignFirstResponder];
}
- (UIToolbar *)addToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.view.frame), 40)];
    toolbar.tintColor = [UIColor blueColor];
    toolbar.backgroundColor = [UIColor colorWithHexString:@"f8f8f8"];
  
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    toolbar.items = @[cancel,space, bar];
    return toolbar;
}
- (IBAction)getCode:(id)sender {
    if (![steyHelper isValidatePhone:self.phoneText.text] ) {
        [smartHUD alertText:self.view alert:@"手机号错误" delay:1];
        return;
    }
    //请求验证码接口,成功后
    [[YKUserManager sharedManager]getVetifyCodeWithPhone:self.phoneText.text OnResponse:^(NSDictionary *dic) {
        [self timeOrder];
    }];
    
}
-(void)timeOrder{
    
    timeNum = 30;
    self.getVetifyBtn.userInteractionEnabled = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countNum) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    
}
//倒计时
-(void)countNum{
    
    if (timeNum == 0) {
        self.getVetifyBtn.userInteractionEnabled = YES;
        [timer invalidate];
        [self.getVetifyBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        [self.getVetifyBtn setTitleColor:mainColor forState:UIControlStateNormal];
        
    }else{
        
        timeNum--;
         self.getVetifyBtn.userInteractionEnabled = NO;
        [self.getVetifyBtn setTitle:[NSString stringWithFormat:@"%lds",(long)timeNum] forState:UIControlStateNormal];
        [self.getVetifyBtn setTitleColor:[UIColor colorWithHexString:@"afafaf"] forState:UIControlStateNormal   ];
    }
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)login:(id)sender {
    
    if (self.phoneText.text.length == 0) {
        [smartHUD alertText:self.view alert:@"手机号错误" delay:1];
        return;
    }else {
        if (![steyHelper isValidatePhone:self.phoneText.text] ) {
            [smartHUD alertText:self.view alert:@"手机号错误" delay:1];
            return;
        }
    }
    if (self.vetifyText.text.length == 0) {
        [smartHUD alertText:self.view alert:@"验证码不能为空" delay:1];
        return;
    }
    
    [[YKUserManager sharedManager]LoginWithPhone:self.phoneText.text VetifyCode:self.vetifyText.text OnResponse:^(NSDictionary *dic) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
}
//qq登录
- (IBAction)tencentLogin:(id)sender {
    [[YKUserManager sharedManager]loginByTencentOnResponse:^(NSDictionary *dic) {

    }];
}

//微信登录
- (IBAction)weChatLogin:(id)sender {
    [[YKUserManager sharedManager]loginByWeChatOnResponse:^(NSDictionary *dic) {
        
    }];
}


@end
