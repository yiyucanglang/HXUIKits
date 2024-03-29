//
//  HXWebView.m
//  ParentDemo
//
//  Created by James on 2019/6/14.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import "HXWebView.h"
#import <Masonry/Masonry.h>
#import <KVOController/KVOController.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface HXJSInteractMiddler : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id scriptDelegate;

- (instancetype)initWithDelegate:(id)scriptDelegate;

@end

@implementation HXJSInteractMiddler

- (instancetype)initWithDelegate:(id)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@interface HXWebViewDelegateInterceptor : NSObject
@property (nonatomic, weak) id originalReceiver;
@property (nonatomic, weak) HXWebView *middleMan;
@end

@implementation HXWebViewDelegateInterceptor

#pragma mark - System Method
- (BOOL)respondsToSelector:(SEL)aSelector {
    
    if ([self.originalReceiver respondsToSelector:aSelector]) {
        return YES;
    }
    if ([self.middleMan respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
    
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    if ([self.originalReceiver respondsToSelector:aSelector]) {
        return self.originalReceiver;
    }
    if ([self.middleMan respondsToSelector:aSelector]) {
        return self.middleMan;
    }
    return self.originalReceiver;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSString *methodName =NSStringFromSelector(aSelector);
    if ([methodName hasPrefix:@"_"]) {//对私有方法不进行crash日志采集操作
        return nil;
    }
    NSString *crashMessages = [NSString stringWithFormat:@"crashProtect: [%@ %@]: unrecognized selector sent to instance",self,NSStringFromSelector(aSelector)];
    NSMethodSignature *signature = [HXWebViewDelegateInterceptor instanceMethodSignatureForSelector:@selector(crashProtectCollectCrashMessages:)];
    [self crashProtectCollectCrashMessages:crashMessages];
    return signature;//对methodSignatureForSelector 进行重写，不然不会调用forwardInvocation方法
    
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    //将此方法进行重写，在里这不进行任何操作，屏蔽会产生crash的方法调用
}


#pragma mark - Private
- (void)crashProtectCollectCrashMessages:(NSString *)crashMessage{
    
//    HXLog(@"%@",crashMessage);
    
}


@end


@interface HXWebView()

@property (nonatomic, strong) HXWebViewDelegateInterceptor *wkUIInterceptor;

@property (nonatomic, strong) HXWebViewDelegateInterceptor *wkNavigationInterceptor;

@property (nonatomic, strong) NSMutableDictionary  *registMethodRelationDic;
@property (nonatomic, copy) NSString  *originalURLStr;

@property (nonatomic, strong) NSMutableDictionary  *observerBeginDic;
@property (nonatomic, strong) NSMutableDictionary  *observerEndDic;

@property (nonatomic, copy) NSString  *currentLoadingUrlStr;

@property (nonatomic, assign) HXWebLoadStatus   loadStatus;
@end

@implementation HXWebView
#pragma mark - Life Cycle

#pragma mark - System Method
- (void)setUIDelegate:(id<WKUIDelegate>)UIDelegate {
    self.wkUIInterceptor.originalReceiver = UIDelegate;
    [super setUIDelegate:(id<WKUIDelegate>)self.wkUIInterceptor];
}

- (void)setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate {
    self.wkNavigationInterceptor.originalReceiver = navigationDelegate;
    [super setNavigationDelegate:(id<WKNavigationDelegate>)self.wkNavigationInterceptor];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.KVOControllerNonRetaining unobserveAll];
    [self unregistAllMethodInvokedByWeb];
    [self removeAllObserver];
}

- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request {
    
    if (!self.UIDelegate && !self.navigationDelegate) {//set self as the default delegate of self
        self.UIDelegate         = self;
        self.navigationDelegate = self;
    }
    return [super loadRequest:request];
}

#pragma mark - Public Method
- (void)loadURLStr:(NSString *)URLStr {
    if (!URLStr) {
        return;
    }
    
    self.originalURLStr = URLStr;
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLStr]];
    mutableRequest.cachePolicy = self.cachePolicy;
    [self loadRequest:mutableRequest];
    [self showProgressView];
}

- (void)registMethodInvokedByWeb:(NSString *)methodName nativeHandler:(WebInvokeNativeHandler)nativeHandler {
    [self unregistMethodInvokedByWeb:methodName];
    
    [self.registMethodRelationDic setValue:[nativeHandler copy] forKey:methodName];
    [self.configuration.userContentController addScriptMessageHandler:[[HXJSInteractMiddler alloc] initWithDelegate:self] name:methodName];
}

- (void)unregistMethodInvokedByWeb:(NSString *)methodName {
    if (self.registMethodRelationDic[methodName]) {
        [self.configuration.userContentController removeScriptMessageHandlerForName:methodName];
    }
    [self.registMethodRelationDic removeObjectForKey:methodName];
}

- (void)unregistAllMethodInvokedByWeb {
    for (NSString *methodName in self.registMethodRelationDic.allKeys) {
        [self unregistMethodInvokedByWeb:methodName];
    }
}

- (void)invokeWebMethod:(NSString *)jsString completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    [self evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(result, error);
        }
    }];
}

- (void)addObserver:(id)observer loadBeginHandler:(LoadBeginHandler)loadBeginHandler loadEndHandler:(LoadEndHandler)loadEndHandler {
    if (!observer) {
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%p", observer];
    self.observerBeginDic[key] = loadBeginHandler;
    self.observerEndDic[key]   = loadEndHandler;
}

- (void)removeObserver:(id)observer {
    NSString *key = [NSString stringWithFormat:@"%p", observer];
    [self.observerBeginDic removeObjectForKey:key];
    [self.observerEndDic  removeObjectForKey:key];
}

- (void)removeAllObserver {
    self.observerBeginDic = nil;
    self.observerEndDic = nil;
}

- (void)loadWillStart:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    self.currentLoadingUrlStr  = webView.URL.absoluteString;
    
    [self _notiObserverLoadBeginWithLoadURL:webView.URL];
    
    self.loadStatus = HXWebLoadStatus_Loading;
    [self addView:self.hudView targetView:self];
    [self showProgressView];
}

- (void)loadFail:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    self.loadStatus = HXWebLoadStatus_Fail;
    
    [self.hudView removeFromSuperview];
    [self hiddenProgressView];
    [self addView:self.failView targetView:self];
    [self _notiObserverLoadEnd:error URL:webView.URL];
}

- (void)loadSuccess:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    self.loadStatus = HXWebLoadStatus_Success;
    
    [self hiddenProgressView];
    [self.failView removeFromSuperview];
    [self.hudView removeFromSuperview];
    [self _notiObserverLoadEnd:nil URL:webView.URL];
}

#pragma mark - Override


#pragma mark - Private Method

- (void)_hxReload {
    [self loadURLStr:self.currentLoadingUrlStr ?: self.originalURLStr];
}

- (void)_whiteScreenCheck {
//    if(self.loadSuccessFlag && !self.title.length) {//whitescreen happen
////        [self _hxReload];
//        if ([self respondsToSelector:@selector(_updateVisibleContentRects)]) {
//            ((void(*)(id,SEL,BOOL))objc_msgSend)(self, @selector(_updateVisibleContentRects),NO);
//        }
//    }
}

- (void)_notiObserverLoadBeginWithLoadURL:(NSURL *)URL {
    for (NSString *key in self.observerBeginDic.allKeys) {
        LoadBeginHandler handler = self.observerBeginDic[key];
        if (handler) {
            handler(URL);
        }
    }
}

- (void)_notiObserverLoadEnd:(NSError *)error URL:(NSURL *)URL {
    BOOL success = error ? NO : YES;
    for (NSString *key in self.observerEndDic.allKeys) {
        LoadEndHandler handler = self.observerEndDic[key];
        if (handler) {
            handler(URL, success, error);
        }
    }
}

#pragma mark Tool
- (void)showProgressView {
    self.progressView.hidden = NO;
    [self bringSubviewToFront:self.progressView];
}

- (void)hiddenProgressView {
    self.progressView.hidden = YES;
}

- (UIViewController *)hxViewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)addView:(UIView *)sourceView targetView:(UIView *)targetView {
    [targetView addSubview:sourceView];
    [sourceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(targetView);
        make.size.equalTo(targetView);
    }];
    
}

#pragma mark - Delegate
#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self.hxViewController presentViewController:alertController animated:YES completion:nil];
    
}

// this method handle the problem in the following
//WKWebView 加载完链接后点击内部链接无法跳转，是因为<a href = "xxx" target = "_black"> 中的target = "_black" 是打开新的页面，所以无法在当前页面打开，需要在当前页重新加载url
//a 超连接中target的意思
//　　_blank -- 在新窗口中打开链接
//　　_parent -- 在父窗体中打开链接
//　　_self -- 在当前窗体打开链接,此为默认值
//　　_top -- 在当前窗体打开链接，并替换当前的整个窗体(框架页)
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    [self loadWillStart:webView didStartProvisionalNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   
    [self loadSuccess:webView didFinishNavigation:navigation];
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    [self loadFail:webView didFailProvisionalNavigation:navigation withError:error];
    
    
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self _hxReload];
}



#pragma mark WeakScriptMessageDelegate
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (self.registMethodRelationDic[message.name]) {((WebInvokeNativeHandler)self.registMethodRelationDic[message.name])(message);
    }
}




#pragma mark - Setter And Getter
- (NSMutableDictionary *)registMethodRelationDic {
    if (!_registMethodRelationDic) {
        _registMethodRelationDic = [[NSMutableDictionary alloc] init];
    }
    return _registMethodRelationDic;
}

- (void)setHudView:(UIView *)hudView {
    [_hudView removeFromSuperview];
    _hudView = hudView;
}

- (void)setFailView:(UIView *)failView {
    [_failView removeFromSuperview];
    _failView = failView;
    if (!self.foribbdenAutoReloadWhenClickFailView) {
        UIButton *click = [UIButton new];
        [click addTarget:self action:@selector(_hxReload) forControlEvents:UIControlEventTouchUpInside];
        [failView addSubview:click];
        [click mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(failView);
        }];
    }
}

- (void)setProgressView:(UIProgressView *)progressView {
    
    [progressView removeFromSuperview];
    _progressView = progressView;
    [self addSubview:progressView];
    progressView.hidden = YES;
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(2));
    }];
    __weak typeof(self) w_self = self;
    [self.KVOControllerNonRetaining unobserveAll];
    [self.KVOControllerNonRetaining observe:self keyPath:FBKVOClassKeyPath(WKWebView, estimatedProgress) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        progressView.progress = w_self.estimatedProgress;
        
        if (w_self.progressView.progress >= 1) {
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                progressView.hidden = YES;
            } completion:nil];
            
        }
    }];
    
}

- (HXWebViewDelegateInterceptor *)wkUIInterceptor {
    if (!_wkUIInterceptor) {
        _wkUIInterceptor = [[HXWebViewDelegateInterceptor alloc] init];
        _wkUIInterceptor.middleMan = self;
    }
    return _wkUIInterceptor;
}

- (HXWebViewDelegateInterceptor *)wkNavigationInterceptor {
    if (!_wkNavigationInterceptor) {
        _wkNavigationInterceptor = [[HXWebViewDelegateInterceptor alloc] init];
        _wkNavigationInterceptor.middleMan = self;
    }
    return _wkNavigationInterceptor;
}

- (NSMutableDictionary *)observerBeginDic {
    if (!_observerBeginDic) {
        _observerBeginDic = [[NSMutableDictionary alloc] init];
    }
    return _observerBeginDic;
}

- (NSMutableDictionary *)observerEndDic {
    if (!_observerEndDic) {
        _observerEndDic = [[NSMutableDictionary alloc] init];
    }
    return _observerEndDic;
}


#pragma mark - Dealloc
@end
