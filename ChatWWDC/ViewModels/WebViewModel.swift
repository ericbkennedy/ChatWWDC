//
//  WebViewModel.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import Foundation
import WebKit

class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate {

    @Published var urlString = "https://developer.apple.com/videos/play/wwdc2023/10149"
    
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
        }
    }
    
}
