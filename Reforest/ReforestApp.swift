//
//  ReforestApp.swift
//  Reforest
//
//  Created by 헌도리 on 11/28/24.
//

import SwiftUI

@main
struct ReforestApp: App {
    let persistenceController = PersistenceController.shared // Core Data를 관리하기 위해 사용 .shared는 앱 전체에서 동일한 데이터 컨트롤러를 사용하도록

    var body: some Scene {
        WindowGroup {
            ContentView() // 앱에서 첫번째 화면으로 표시될 SwiftUI뷰
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Core Data의 viewContext를 SwiftUI 환경에 추가하여, SwiftUI의 뷰들이 쉽게 Core Data에 접근하고 데이터를 관리할 수 있도록 합니다.
        }
    }
}
