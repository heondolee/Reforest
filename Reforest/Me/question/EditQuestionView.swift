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
                        listStyle: .none,
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
                Text("나 - 질문 수정하기")
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
            HStack {
                ForEach(vm.meCategoryModelList) { category in
                    Text(category.title)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(category.id == vm.selectedCategory.id ? Color.blue : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(category.id == vm.selectedCategory.id ? .white : .black)
                        .onTapGesture {
                            vm.selectedCategory = category
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
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
                    ForEach(content.subLines.indices, id: \.self) { index in
                        renderSubLine(subLine: $content.subLines[index])
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbar()
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func renderSubLine(subLine: Binding<SubLineModel>) -> AnyView {
        return AnyView(
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if subLine.wrappedValue.listStyle == .checkbox {
                        Image(systemName: "checkmark.square")
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

