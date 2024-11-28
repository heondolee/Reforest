//
//  ViewExtension.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import SwiftUI

extension View {
    func whiteBoxWithShadow(padding: (horizontal: CGFloat, vertical: CGFloat) = (20, 20), lineSpacing: CGFloat) -> some View {
        self
            .padding(.horizontal, padding.horizontal)
            .padding(.vertical, padding.vertical)
            .frame(maxWidth: .infinity)
            .background(.white)
            .lineSpacing(lineSpacing)
            .cornerRadius(12)
            .shadow(
                color: .black.opacity(0.1),
                radius: CGFloat(15),
                x: CGFloat(0), y: CGFloat(3)
            )
    }
}
