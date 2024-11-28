//
//  EditQuestionView.swift
//  Reforest
//
//  Created by 가은리 on 11/29/24.
//

import SwiftUI

struct EditQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm: MeViewModel
    
    @State var content: ContentModel
    
    @FocusState private var isKeyBoardOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            NavigationView()
            ContentEditView()
        }
        .onAppear {
            isKeyBoardOn = true
        }
    }
}

extension EditQuestionView {
    private func NavigationView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("나 - 질문 수정하기")
                    .font(Font.system(size: 22, weight: .bold))
                Spacer()
                Text("취소")
                    .foregroundStyle(.gray)
                    .font(Font.system(size: 20, weight: .bold))
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(.trailing, 30)
                Button {
                    vm.updateSubLineText(editContent: content)
                    dismiss()
                } label: {
                    Text("완료")
                        .font(Font.system(size: 20, weight: .bold))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
            Divider()
        }
    }
    private func ContentEditView() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .zero) {
                    TextField("질문을 입력하세요.", text: $content.headLine)
                        .tint(.black)
                        .font(Font.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .focused($isKeyBoardOn)
                        .padding(.bottom, 10)
                    SubLineListView()
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .frame(maxHeight: .infinity)
        .background(.white)
    }
    @ViewBuilder
    private func SubLineListView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                Image(.arrow)
                    .frame(width: 24, height: 24)
                TextField("질문에 답을 해보세요.", text: $content.subLine.text)
                    .tint(.black)
                    .font(Font.system(size: 14))
            }
        }
    }
}

#Preview {
    EditQuestionView(vm: MeViewModel(), content: ContentModel(id: UUID(), headLine: "나의 장점", subLine: SubLineModel(id: UUID(), text: "신중하고 남의 공감을 잘함")))
}
