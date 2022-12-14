//
//  ContentWebViewNavigationDelegate.swift
//  zapp
//
//  Created by Joe Manto on 9/4/21.
//

import Foundation
import WebKit

extension WebViewController: WKNavigationDelegate {
 
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
       
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = self.webView.url {
            self.updateAddressBar(with: url.absoluteString)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logging.shared.log(msg: "did fail navigation", comp: "[WKNavigationDelegate]", type: .err)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        decisionHandler(true)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, .none)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        let webpagePref = WKWebpagePreferences()
        webpagePref.allowsContentJavaScript = true
        webpagePref.preferredContentMode = .desktop
        
        decisionHandler(.allow, webpagePref)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if error._code != NSUserCancelledError {
            Util.showAlert(msg: "Invalid Url")
        }
        Logging.shared.log(msg: "did fail to provision navigation", comp: "[WKNavigationDelegate]", type: .err)
    }
}
