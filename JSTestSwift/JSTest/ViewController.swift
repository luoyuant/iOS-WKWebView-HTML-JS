//
//  ViewController.swift
//  JSTest
//
//  Created by luoyuan on 2018/6/9.
//  Copyright © 2018年 luoyuan. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
    
    var webView: WKWebView?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config: WKWebViewConfiguration = WKWebViewConfiguration();
        config.userContentController.add(WeakScriptMessageDelegate.initWith(self), name: "callTemplate");
        let scriptSource: String = """
            window.jSBridgeInstance = window.webkit.messageHandlers.callTemplate;
            window.jSBridgeInstance.sendMessage = function(act, json) {
                    var jsonDict = {
                        "key1": act,
                        "key2": json
                    };
                    window.webkit.messageHandlers.callTemplate.postMessage(jsonDict);
            }
        """;
        let script:WKUserScript = WKUserScript.init(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false);
        config.userContentController.addUserScript(script);
        webView = WKWebView.init(frame: self.view.bounds, configuration: config);
        webView?.load(URLRequest.init(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "jsTest", ofType: "html")!)));
        //webView?.load(URLRequest.init(url: URL.init(string: "https://a.f598.com:446/app/mall/index")!));
        self.view.addSubview(webView!);
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body);
        var dic: Dictionary<String, Any>? = message.body as? Dictionary<String, Any>;
        print(dic?["key1"] as? String ?? "");
        if dic?["key1"] as? String == "SHARE" {
            print("ddddd")
            webView?.load(URLRequest.init(url: URL.init(string: "http://a.f598.com//app/book/index")!));
        }
    }

}



class WeakScriptMessageDelegate: NSObject, WKScriptMessageHandler {
    
    weak var delegate: WKScriptMessageHandler?;
    
    class func initWith(_ delegate: WKScriptMessageHandler?) -> WeakScriptMessageDelegate {
        let del: WeakScriptMessageDelegate = WeakScriptMessageDelegate();
        del.delegate = delegate;
        return del;
    }
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (delegate != nil) {
            
            delegate?.userContentController(userContentController, didReceive: message);
        }
    }
    
}
