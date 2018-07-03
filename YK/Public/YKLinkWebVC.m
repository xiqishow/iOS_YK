//
//  YKLinkWebVC.m
//  YK
//
//  Created by LXL on 2018/1/10.
//  Copyright © 2018年 YK. All rights reserved.
//

#import "YKLinkWebVC.h"
#import "YKMainVC.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "YKToBeVIPVC.h"
#import "YKLoginVC.h"

@protocol JSObjectDelegate <JSExport>
-(void)callme:(NSString *)string;
-(void)share:(NSString *)shareUrl;
@end

@interface YKLinkWebVC ()<UIWebViewDelegate,JSObjectDelegate>{
    UILabel *title;
}

@property (nonatomic,strong)UIWebView *webView;
@property(nonatomic, strong) JSContext *context;
@property (nonatomic,strong)UIActivityIndicatorView *indicatorView;

//关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeItem;
// 返回按钮
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *flexSpacer;

@end

@implementation YKLinkWebVC

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self creatWeb];
    self.webView.scrollView.bounces = NO;
    
}

- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor whiteColor];
//    self.title = @"衣庫";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 44);
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11) {
        btn.frame = CGRectMake(0, 0, 44, 44);;//ios7以后右边距默认值18px，负数相当于右移，正数左移
    }
    btn.adjustsImageWhenHighlighted = NO;
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:btn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -8;//ios7以后右边距默认值18px，负数相当于右移，正数左移
    if ([[UIDevice currentDevice].systemVersion floatValue]< 11) {
        negativeSpacer.width = -18;
    }
    self.navigationItem.leftBarButtonItems=@[negativeSpacer,item];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
    title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 30)];
    
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor colorWithHexString:@"1a1a1a"];
    title.font = PingFangSC_Semibold(20);;

    self.navigationItem.titleView = title;
    [self creatWeb];
}

- (void)leftAction{
    if (_status == 1) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        window.rootViewController = [YKMainVC new];
        
        CATransition *anim = [CATransition animation];
        anim.duration = 0.3;
        anim.type = @"fade";
        [[UIApplication sharedApplication].keyWindow.layer addAnimation:anim forKey:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)creatWeb{
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, WIDHT, HEIGHT-64)];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSURL* url = [NSURL URLWithString:[self URLEncodedString:_url]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-10, self.view.frame.size.height/2-10, 20, 20)];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_indicatorView startAnimating];
    [self.view addSubview:_indicatorView];
    _indicatorView.hidden = NO;
}

- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

-(void)webViewDidFinishLoad:(UIWebView*)webView {
    
   
    NSString *allHtml =[_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    //获取网页title
    
    NSString *htmlTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];

    if ([htmlTitle length] == 0) {
        title.text = @"衣库";
    }else {
        title.text = htmlTitle;
    }

    _indicatorView.hidden = YES;
    
    //TEST
    
    //捕捉异常回调
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息: %@",exceptionValue);
    };
    //通过JSExport协议关联Native的方法
    self.context[@"Native"] = self;
    
    //通过block形式关联JavaScript中的函数
    __weak typeof(self) weakSelf = self;
    
    self.context[@"GoToPayPage"] = ^(NSString *message) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"this is a message" message:message preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertControl addAction:cancelAction];
            [strongSelf.navigationController presentViewController:alertControl animated:YES completion:nil];
        });
        };
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestString = [[[request URL] absoluteString]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    if ([requestString containsString:@"next:"]){
        NSLog(@"=====================");
        if ([Token length] == 0) {
            YKLoginVC *vip = [[YKLoginVC alloc]initWithNibName:@"YKLoginVC" bundle:[NSBundle mainBundle]];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vip];
            
            [self presentViewController:nav animated:YES completion:^{
                
            }];
            return YES;
        }
        YKToBeVIPVC *vip = [[YKToBeVIPVC alloc]initWithNibName:@"YKToBeVIPVC" bundle:[NSBundle mainBundle]];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vip];
        
        [self presentViewController:nav animated:YES completion:^{
            
        }];
        
        
    };
              
    NSLog(@"requestString : %@",requestString);


    NSArray *components = [requestString componentsSeparatedByString:@"|"];
    NSLog(@"=components=====%@",components);


    NSString *str1 = [components objectAtIndex:0];
    NSLog(@"str1:::%@",str1);


    NSArray *array2 = [str1 componentsSeparatedByString:@"/"];
    NSLog(@"array2:====%@",array2);


    NSInteger coun = array2.count;
    NSString *method = array2[coun-1];
    NSLog(@"method:===%@",method);

    if ([method isEqualToString:@"active.html"])
    {
        NSLog(@"h5点击事件1");
        
   
    }else if ([method isEqualToString:@"InviteBtn2"]){
   
        NSLog(@"h5点击事件2");
    }
        return YES;
}
#pragma mark - JSExport Methods
-(void)callme:(NSString *)string
{
    NSLog(@"%@",string);
}

-(void)share:(NSString *)shareUrl
{
    NSLog(@"分享的url=%@",shareUrl);
    JSValue *shareCallBack = self.context[@"shareCallBack"];
    [shareCallBack callWithArguments:nil];
}

-(void)webView:(UIWebView*)webView DidFailLoadWithError:(NSError*)error{
    _indicatorView.hidden = YES;
}



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = YES;
}



@end
