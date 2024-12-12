//
//  VisonView.swift
//  Reforest
//
//  Created by Heondo Lee on 12/3/24.
//

import Foundation
import SwiftUI

struct VisionView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                navigationView()
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        Image("Vision")
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
        }
    }
}

extension VisionView {
    private func navigationView() -> some View {
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
