//
//  SWChatWebViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatWebViewController.h"
#import <WebKit/WebKit.h>
@interface SWChatWebViewController ()
<
WKUIDelegate,
WKNavigationDelegate,
UIGestureRecognizerDelegate
>{
        UITapGestureRecognizer* _singleTap;
}
@property (nonatomic, strong) WKWebView *wkWebview;
@property (nonatomic,strong) UIProgressView *progress;

@end

@implementation SWChatWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //TODO:加载
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", _url_string]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.wkWebview loadRequest:request];
    //TODO:kvo监听，获得页面title和加载进度值
    [self.wkWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebview addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnclikeWeb:)];
      _singleTap.delegate= self;
      _singleTap.cancelsTouchesInView = NO;
      [_wkWebview addGestureRecognizer:_singleTap];
      [_wkWebview.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
      
    
}
- (void)OnclikeWeb:(UITapGestureRecognizer *)tap{
    
    _wkWebview.scrollView.bounces=NO;
    if (tap.state==UIGestureRecognizerStateEnded) {
        _wkWebview.scrollView.bounces = YES;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
    
}


-(void)setUrl_string:(NSString *)url_string{
    _url_string = url_string;
   
}
#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        if (object == self.wkWebview)
        {
            [self.progress setAlpha:1.0f];
            [self.progress setProgress:self.wkWebview.estimatedProgress animated:YES];
            if(self.wkWebview.estimatedProgress >= 1.0f)
            {
                [UIView animateWithDuration:0.5f
                                      delay:0.3f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.progress setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished) {
                                     [self.progress setProgress:0.0f animated:NO];
                                 }];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    //网页title
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.wkWebview)
        {
//            if (_url_title.length ==0) {
                self.title = self.wkWebview.title;
//                self.navView.titleLable.text = self.wkWebview.title;
//            }
            
        }else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark --- wk
- (WKWebView *)wkWebview
{
    if (_wkWebview == nil)
    {
        _wkWebview = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT +SafeBottomHeight)];
        _wkWebview.UIDelegate = self;
        _wkWebview.navigationDelegate = self;
        _wkWebview.backgroundColor =  [SWKit colorWithHexString:@"#FAFAFA"];
        _wkWebview.allowsBackForwardNavigationGestures = YES;
        [self.view addSubview:_wkWebview];
     
    }
    return _wkWebview;
}

-(void)dealloc{
    SWLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.wkWebview removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebview removeObserver:self forKeyPath:@"title"];
}

#pragma mark ------- WKNavigationDelegate -----
//网页开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //    self.currentUrl = webView.URL.absoluteString;
    //    NSLog(@"currentUrl====%@",self.currentUrl);
}


//网页加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (webView.backForwardList.backList.count > 0) {
        //        self.navigationItem.leftBarButtonItems = @[self.backItem,self.closeItem];
    }
  
    //通过js获取htlm中图片url
    //    [webView getImageUrlByJS:webView];
}

//网页加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}
@end
