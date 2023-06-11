//
//  WebViewModel.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import Foundation
import WebKit

class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate {

    @Published var urlString = ""
    @Published var transcript = ""
    
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView loaded" )
        if webView.url?.absoluteString.contains("developer.apple.com") == true {
            webView.evaluateJavaScript("document.querySelector('li.transcript')?.innerText") { (result, error) in
                guard error == nil else {
                    print("Error parsing transcript", String(describing: error))
                    return
                }
                if let resultNSString = result as? NSString { // Cast callback NSString object to a struct (Swift String)
                    self.trimTranscript(resultNSString as String)
                }
            }
        }
    }
    
    func trimTranscript(_ result: String) {
        var trimmedString = result
        if let prefixRange = trimmedString.range(of: "Download") {
            trimmedString.removeSubrange(prefixRange)
        }
        if trimmedString.hasPrefix("Array") {
            self.transcript = ""
        } else {
            self.transcript = trimmedString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        print("Transcript is \(self.transcript.count) long")
    }
}
