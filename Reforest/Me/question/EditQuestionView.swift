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
    
    var body: some View {
        VStack {
            NavigationView()
            CategorySelectorView()
            ContentEditView()
        }
        .onAppear {
            isKeyBoardOn = true // 화면 뜨면 바로 키보드
        }
        .alert(isPresented: $isShowEmptyAlert) {
            Alert(title: Text("내용을 모두 입력해주세요"), dismissButton: .default(Text("확인")))
        }
    }
}

// 상단 카테고리 선택
@ViewBuilder
private func CategorySelectorView() -> some View {
    HStack {
        TextField("카테고리를 입력하세요.", text: $vm.selectedCategory.title)
            .font(Font.system(size: 16, weight: .bold))
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))
            .padding(.horizontal, 20)
        Spacer()
    }
}

// 키보드 도구막대
private func KeyboardToolbar() -> some View {
    HStack {
        Button(action: { tabIndent() }) {
            Image(systemName: "arrow.right.to.line")
        }
        Button(action: { untabIndent() }) {
            Image(systemName: "arrow.left.to.line")
        }
        Spacer()
        Button(action: { toggleListStyle(.checkbox) }) {
            Image(systemName: "checklist")
        }
        Button(action: { toggleListStyle(.numbered) }) {
            Image(systemName: "list.number")
        }
        Button(action: { toggleListStyle(.bulleted) }) {
            Image(systemName: "list.bullet")
        }
    }
    .padding()
    .background(Color(UIColor.systemGray6))
}

// 본문 수정 영역
private func ContentEditView() -> some View {
    VStack(alignment: .leading, spacing: 16) {
        TextField("질문을 입력하세요.", text: $content.headLine)
            .font(Font.system(size: 18, weight: .semibold))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .focused($isKeyBoardOn)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(content.subLines) { subLine in
                    HStack {
                        // 리스트 스타일별 UI 표시
                        if subLine.listStyle == .checkbox {
                            Image(systemName: "checkmark.square")
                        } else if subLine.listStyle == .numbered {
                            Text("\(content.subLines.firstIndex(of: subLine)! + 1).")
                        } else if subLine.listStyle == .bulleted {
                            Circle().frame(width: 8, height: 8)
                        }
                        TextField("답변을 입력하세요.", text: $content.subLines.first { $0.id == subLine.id }!.text)
                            .padding(.leading, CGFloat(subLine.indentLevel) * 10)
                            .focused($isKeyBoardOn)
                    }
                }
            }
        }
    }
    .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
            KeyboardToolbar()
        }
    }
}

// Tab/Untab 기능
private func tabIndent() {
    if let selectedLine = content.subLines.last {
        content.subLines.first { $0.id == selectedLine.id }?.indentLevel += 1
    }
}

private func untabIndent() {
    if let selectedLine = content.subLines.last, selectedLine.indentLevel > 0 {
        content.subLines.first { $0.id == selectedLine.id }?.indentLevel -= 1
    }
}

// 리스트 스타일 토글
private func toggleListStyle(_ style: ListStyle) {
    if let selectedLine = content.subLines.last {
        if selectedLine.listStyle == style {
            content.subLines.first { $0.id == selectedLine.id }?.listStyle = .none
        } else {
            content.subLines.first { $0.id == selectedLine.id }?.listStyle = style
        }
    }
}


extension EditQuestionView {
    private func NavigationView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("나 - 수정하기")
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
    if let firstCategory = mockData_meCategoryModelList.first,
       let firstContent = firstCategory.contentList.first {
        EditQuestionView(
            vm: MeViewModel(
                meCategoryModelList: mockData_meCategoryModelList,
                profile: mockData_profile
            ),
            content: firstContent, // "성격" 카테고리의 첫 번째 콘텐츠
            isShowEmptyAlert: false,
            isThisEditView: true,
            meCategoryID: firstCategory.id
        )
    } else {
        Text("Mock 데이터가 비어있습니다.")
    }
}
