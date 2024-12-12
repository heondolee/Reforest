import SwiftUI

struct PlanView: View {
    var body: some View {
        VStack(spacing: 0) {
            TopView()
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    Image("Plan")
                        .resizable()
                        .scaledToFill()
                }
            }
        }
    }
}

extension PlanView {
    private func TopView() -> some View {
        VStack(spacing: .zero) {
            Image("PlanTitle")
                .resizable()
                .scaledToFit()
            Divider()
                .padding(.bottom, 20)
        }
    }
}
