//
//  ChatWWDCApp.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import SwiftUI

@main
struct ChatWWDCApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
