//
//  HXWebView.h
//  ParentDemo
//
//  Created by James on 2019/6/14.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import <WebKit/WebKit.h>

typedef void(^WebInvokeNativeHandler)(WKScriptMessage * _Nonnull message);

typedef void(^LoadBeginHandler)(void);

typedef void(^LoadEndHandler)(BOOL success, NSError *error);

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

@property (nonatomic, assign, readonly) BOOL   loadSuccessFlag;


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
@end

NS_ASSUME_NONNULL_END
