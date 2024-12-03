//
//  NavigationView.swift
//  Reforest
//
//  Created by Heondo Lee on 12/3/24.
//

import Foundation
import SwiftUI


struct MainTabView: View {
    var body: some View {
        VStack {
            TabView {
                // 홈 탭
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("홈")
                    }
                
                // 나 탭
                MeView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("나")
                    }
                
                // 계획 탭
                PlanView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("계획")
                    }
                
                // 비전 탭
                VisionView()
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("비전")
                    }
                
                // 소셜 탭
                SocialView()
                    .tabItem {
                        Image(systemName: "globe")
                        Text("소셜")
                    }
            }
            .accentColor(.black) // 활성 탭 색상 설정
            
            Divider() // 탭바 바로 위에 가로선 추가
                .frame(height: 1)
                .background(Color.gray.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.bottom) // 탭바와 영역이 겹치지 않도록 설정
    }
}

#Preview {
    MainTabView()
}
