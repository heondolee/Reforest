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
            self._content = State(initialValue: ContentModel(
                id: UUID(),
                headLine: "",
                subLines: [
                    SubLineModel(
                        id: UUID(),
                        text: "",
                        indentLevel: 0,
                        listStyle: .none, // 초기화할 때 리스트 스타일 설정
                        isChecked: false, // 기본값은 체크되지 않음
                        subLines: [] // 계층 구조 초기화
                    )
                ]
            ))
            self.isThisEditView = false
        }
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationHeaderView()
            CategorySelectorView()
            ContentEditView()
            Spacer()
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
    
    private func NavigationHeaderView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(isThisEditView ? "나 - 수정하기" : "나 - 추가하기")
                    .font(Font.system(size: 22, weight: .bold))
                Spacer()
                Text("취소")
                    .foregroundColor(.gray)
                    .font(Font.system(size: 20, weight: .bold))
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(.trailing, 30)
                Button {
                    if content.headLine.isEmpty || content.subLines.allSatisfy({ $0.text.isEmpty }) {
                        isShowEmptyAlert = true
                    } else {
                        if isThisEditView {
                            vm.updateContent(MeCategoryID: meCategoryID, editContent: content)
                        } else {
                            vm.addContent(MeCategoryID: meCategoryID, addContent: content)
                        }
                        dismiss()
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
    
    @ViewBuilder
    private func CategorySelectorView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .zero) {
                ForEach(vm.meCategoryModelList) { category in
                    let isSelected = category.id == vm.selectedCategory.id
                    Text(category.title)
                        .font(Font.system(size: 17, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(isSelected ? .white : .clear)
                        .cornerRadius(100)
                        .onTapGesture {
                            vm.selectedCategory = category
                        }
                }
            }
            .padding(8)
            .background(.gray.opacity(0.1))
            .cornerRadius(25)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .shadow(
                color: .black.opacity(0.1),
                radius: CGFloat(8),
                x: CGFloat(0), y: CGFloat(3)
            )
        }
    }
    
    private func ContentEditView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("질문을 입력하세요.", text: $content.headLine)
                .font(Font.system(size: 20, weight: .heavy))
                .focused($isKeyBoardOn)
                .padding(.horizontal, 6)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(content.subLines.indices, id: \.self) { index in
                    renderSubLine(subLine: $content.subLines[index])
                }
            }
            .padding(.horizontal, 10)

        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbar()
            }
        }
        .whiteBoxWithShadow(lineSpacing: 8)
        .padding(.horizontal, 20)
    }

    private func renderSubLine(subLine: Binding<SubLineModel>) -> AnyView {
        return AnyView(
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if subLine.wrappedValue.listStyle == .checkbox {
                        Image(systemName: subLine.wrappedValue.isChecked ? "checkmark.square.fill" : "square")
                            .onTapGesture {
                                toggleCheckBox(for: subLine)
                            }
                    } else if subLine.wrappedValue.listStyle == .numbered {
                        Text("\(subLine.wrappedValue.indentLevel + 1).")
                    } else if subLine.wrappedValue.listStyle == .bulleted {
                        Circle().frame(width: 8, height: 8)
                    }
                    
                    TextField(
                        "답변을 입력하세요.",
                        text: subLine.text
                    )
                    .padding(.leading, CGFloat(subLine.wrappedValue.indentLevel) * 10)
                    .focused($isKeyBoardOn)
                }
                .padding(.vertical, 4)
                
                // 하위 SubLine 렌더링
                ForEach(subLine.wrappedValue.subLines.indices, id: \.self) { childIndex in
                    renderSubLine(
                        subLine: Binding(
                            get: { subLine.wrappedValue.subLines[childIndex] },
                            set: { subLine.wrappedValue.subLines[childIndex] = $0 }
                        )
                    )
                }
            }
            .padding(.leading, CGFloat(subLine.wrappedValue.indentLevel) * 10)
        )
    }
    
    private func toggleCheckBox(for subLine: Binding<SubLineModel>) {
        guard subLine.wrappedValue.listStyle == .checkbox else { return }
        subLine.wrappedValue.isChecked.toggle()
        
        // 업데이트를 ViewModel에 반영
        if let categoryIndex = vm.meCategoryModelList.firstIndex(where: { category in
            category.contentList.contains(where: { content in
                content.subLines.contains(where: { $0.id == subLine.wrappedValue.id })
            })
        }),
           let contentIndex = vm.meCategoryModelList[categoryIndex].contentList.firstIndex(where: { content in
               content.subLines.contains(where: { $0.id == subLine.wrappedValue.id })
           }),
           let subLineIndex = vm.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines.firstIndex(where: { $0.id == subLine.wrappedValue.id }) {
            
            vm.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines[subLineIndex].isChecked.toggle()
        }
    }

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
    
    private func tabIndent() {
        if let selectedLine = content.subLines.last,
           let index = content.subLines.firstIndex(where: { $0.id == selectedLine.id }) {
            content.subLines[index].indentLevel += 1
        }
    }

    private func untabIndent() {
        if let selectedLine = content.subLines.last,
           selectedLine.indentLevel > 0,
           let index = content.subLines.firstIndex(where: { $0.id == selectedLine.id }) {
            content.subLines[index].indentLevel -= 1
        }
    }

    private func toggleListStyle(_ style: ListStyle) {
        if let selectedLine = content.subLines.last,
           let index = content.subLines.firstIndex(where: { $0.id == selectedLine.id }) {
            content.subLines[index].listStyle = content.subLines[index].listStyle == style ? .none : style
        }
    }
}

#Preview {
    // 첫 번째 카테고리에서 첫 번째 ContentModel 선택
    if let firstCategory = mockData_meCategoryModelList.first,
       let firstContent = firstCategory.contentList.first {
        let mockViewModel = MeViewModel(
            meCategoryModelList: mockData_meCategoryModelList,
            profile: mockData_profile
        )
        return EditQuestionView(
            vm: mockViewModel,
            meCategoryID: firstCategory.id,
            content: firstContent
        )
    } else {
        return Text("Mock 데이터가 비어 있습니다.")
    }
}
