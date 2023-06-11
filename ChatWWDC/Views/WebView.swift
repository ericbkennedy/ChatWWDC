//
//  WebView.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    var urlString: String
    
    @ObservedObject var webViewModel: WebViewModel // will be injected
    
    func makeUIView(context: Context) -> WKWebView {
        
        let webView = WKWebView(frame: .zero)
        
        // Let webViewModel be the delegate for this webView so it can evaluateJavaScript
        webViewModel.webView = webView
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        } else {
            print("Error occurred")
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Leave empty so it only changes when WebViewModel changes the URL
    }
}
