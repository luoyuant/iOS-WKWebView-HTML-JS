//
//  ViewController.m
//  JSTestOC
//
//  Created by luoyuan on 2018/6/9.
//  Copyright © 2018年 luoyuan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    [config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"callTemplate"];
    NSString *scriptSource = @"\
        window.jSBridgeInstance = window.webkit.messageHandlers.callTemplate;\
        window.jSBridgeInstance.sendMessage = function(act, json) {\
            var jsonDict = {\
                \"key1\": act,\
                \"key2\": json\
            };\
            window.webkit.messageHandlers.callTemplate.postMessage(jsonDict);\
        }";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:false];
    [config.userContentController addUserScript:script];
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jsTest" ofType:@"html"]]]];
    [self.view addSubview:_webView];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"----> JS");
    NSLog(@"%@", message.body);
}


@end


@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
