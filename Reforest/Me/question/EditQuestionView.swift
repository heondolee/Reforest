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
    @State var isShowEmptyAlert: Bool = false
    
    @FocusState private var isKeyBoardOn: Bool
    
    let isThisEditView: Bool
    let meCategoryID: UUID
    
    init(vm: MeViewModel, meCategoryID: UUID, content: ContentModel?) {
        self.vm = vm
        self.meCategoryID = meCategoryID
        if let content {
            self._content = State(initialValue: content)
            self.isThisEditView = true
        } else {
            self._content = State(initialValue: ContentModel(id: UUID(), headLine: "", subLine: SubLineModel(id: UUID(), text: "")))
            self.isThisEditView = false
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            NavigationView()
            ContentEditView()
        }
        .onAppear {
            isKeyBoardOn = true
        }
        .alert(isPresented: $isShowEmptyAlert) {
            Alert(title: Text("내용을 모두 입력해주세요"), dismissButton: .default(Text("확인")))
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
                    if content.headLine.isEmpty || content.subLine.text.isEmpty {
                        isShowEmptyAlert = true
                    } else {
                        if isThisEditView {
                            vm.updateContent(MeCategoryID: meCategoryID, editContent: content)
                            dismiss()
                        } else {
                            vm.addContent(MeCategoryID: meCategoryID, addContent: content)
                            dismiss()
                        }
                    }
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
    EditQuestionView(vm: MeViewModel(meCategoryModelList: mockData_meCategoryModelList, profile: mockData_profile), meCategoryID: UUID(), content: ContentModel(id: UUID(), headLine: "나의 장점", subLine: SubLineModel(id: UUID(), text: "신중하고 남의 공감을 잘함")))
}
