//
//  VisionView.swift
//  Reforest
//
//  Created by Heondo Lee on 12/4/24.
//

import Foundation
import SwiftUI

struct VisionView: View {
    var body: some View { // body 프로퍼티 추가
        VStack {
            TopView() // 상단 뷰 호출
        }
    }
}

extension VisionView {
    private func TopView() -> some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Text("비전")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 13)
            Divider()
                .padding(.bottom, 20)
        }
    }
}

#Preview {
    VisionView()
}
