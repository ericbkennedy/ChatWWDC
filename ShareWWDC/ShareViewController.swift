//
//  ShareViewController.swift
//  Share
//
//  Created by Eric Kennedy on 6/6/23.
//

import UIKit
import Social

let APP_GROUP = "group.com.chartinsight.chatWWDC"

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        // Called both on initial display and after user edits the text
        // Apple Support says to ignore NSXPCConnection info logged https://developer.apple.com/forums/thread/689603
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.

        guard let sharedItem = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            print("EK no shared item")
            return
        }
        guard let sharedAttachments = sharedItem.attachments else {
            print("No shared attachments")
            return
        }
        
        if let shareText = self.contentText {
            print("Found contentText:", shareText)
        }
        
        for itemProvider: NSItemProvider in sharedAttachments {
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url",
                                      options: nil,
                                      completionHandler: { (url, error) -> Void in
                    if let urlSelected = url as? NSURL {
                        self.shareURL(urlSelected)
                        
                        // Do stuff with your URL now.
                    }
                    super.didSelectPost() // Will inform host app that we're done so it un-blocks its UI.
                })
            } else { // in case the app provides the URL with identifier "public.text" or similar
                // https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html
                itemProvider.registeredTypeIdentifiers.forEach({
                    print("EK consider supporting:", String(describing: $0))
                    
                })
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        // See https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html
        return []
    }
    
    // Note: need to app this extension and the main app to the same app group (under Capabilities)
    // https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html
    
    func shareURL(_ url: NSURL) {
        
        let urlString = url.absoluteString
        
        // app extension can initiate uploads using NSURLSession with results reported to the containing app
        
        let userDefaults = UserDefaults(suiteName: APP_GROUP)
        
        // see https://developer.apple.com/documentation/foundation/userdefaults for options
        
        userDefaults?.set(urlString, forKey: "newURL")
        
        // now verify it has been set
        if let userDefaultsValue = UserDefaults(suiteName: APP_GROUP)?.object(forKey: "newURL") {
            if userDefaultsValue is NSURL {
                print("New URL is \(userDefaultsValue)")
            } else {
                print("was a different kind")
            }
        }
    }
}
