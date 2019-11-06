//
//  HXWebView.h
//  ParentDemo
//
//  Created by James on 2019/6/14.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import <WebKit/WebKit.h>


typedef NS_ENUM(NSInteger, HXWebLoadStatus) {
    HXWebLoadStatus_UnKnown,
    HXWebLoadStatus_Loading,
    HXWebLoadStatus_Fail,
    HXWebLoadStatus_Success,
};

typedef void(^WebInvokeNativeHandler)(WKScriptMessage * _Nonnull message);

typedef void(^LoadBeginHandler)(NSURL *URL);

typedef void(^LoadEndHandler)(NSURL *URL, BOOL success, NSError *error);

NS_ASSUME_NONNULL_BEGIN

//@warning: whem remove from superView all services supplied by self  will be done even you readd it to a view
@interface HXWebView : WKWebView
<
    WKUIDelegate,
    WKNavigationDelegate
>


/**
 default : NSURLRequestUseProtocolCachePolicy
 */
@property (nonatomic, assign) NSURLRequestCachePolicy   cachePolicy;

/**
 default: nil
 */
@property (nonatomic, strong, nullable) UIView  *hudView;

/**
 default: nil
 */
@property (nonatomic, strong, nullable) UIView  *failView;

@property (nonatomic, strong, nullable) UIProgressView  *progressView;

@property (nonatomic, assign) BOOL   foribbdenAutoReloadWhenClickFailView;

@property (nonatomic, assign, readonly) HXWebLoadStatus   loadStatus;

- (void)loadURLStr:(NSString *)URLStr;

//warning : reference circular
- (void)registMethodInvokedByWeb:(NSString *)methodName
       nativeHandler:(WebInvokeNativeHandler)nativeHandler;

- (void)unregistMethodInvokedByWeb:(NSString *)methodName;

- (void)unregistAllMethodInvokedByWeb;

- (void)invokeWebMethod:(NSString *)jsString completionHandler:(void(^)(id _Nullable result, NSError * _Nullable error))completionHandler;

//warning :circular reference
- (void)addObserver:(id)observer
   loadBeginHandler:(LoadBeginHandler _Nullable)loadBeginHandler
  loadEndHandler:(LoadEndHandler _Nullable)loadEndHandler;

- (void)removeObserver:(id)observer;

- (void)removeAllObserver;





- (void)loadWillStart:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;

- (void)loadFail:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;

- (void)loadSuccess:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;


@end

NS_ASSUME_NONNULL_END
