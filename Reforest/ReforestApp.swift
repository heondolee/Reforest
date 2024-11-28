//
//  ReforestApp.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import SwiftUI

@main
struct ReforestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
