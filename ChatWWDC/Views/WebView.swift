//
//  WebView.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    @ObservedObject var webViewModel = WebViewModel()
    
    func makeUIView(context: Context) -> WKWebView {
        
        let webView = WKWebView(frame: .zero)
        
        if let url = URL(string: webViewModel.urlString) {
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

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView()
    }
}
