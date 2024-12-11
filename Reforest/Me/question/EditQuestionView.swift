import SwiftUI

struct EditQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm: MeViewModel
    
    @State var question: QuestionModel
    @State var isShowEmptyAlert: Bool = false
    
    @FocusState private var isKeyBoardOn: Bool
    
    @FocusState private var focusedIndex: Int?
    
    let isThisEditView: Bool
    let meCategoryID: UUID
    
    init(vm: MeViewModel, meCategoryID: UUID, question: QuestionModel?) {
        self.vm = vm
        self.meCategoryID = meCategoryID
        if let question {
            self._question = State(initialValue: question)
            self.isThisEditView = true
        } else {
            self._question = State(initialValue: QuestionModel(
                id: UUID(),
                headLine: "",
                answer: AnswerModel(
                    id: UUID(),
                    subLines: [
                        SubLineModel(
                            id: UUID(),
                            text: "",
                            indentLevel: 0,
                            listStyle: .none, // 초기 리스트 스타일
                            isChecked: false, // 기본값은 체크되지 않음
                            subLines: []      // 초기 하위 subLines
                        )
                    ]
                )
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
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Text("취소")
                    .foregroundColor(.gray)
                    .font(.system(size: 20, weight: .bold))
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(.trailing, 30)

                Button {
                    if question.headLine.isEmpty || question.answer.subLines.allSatisfy({ $0.text.isEmpty }) {
                        isShowEmptyAlert = true
                    } else {
                        let combinedText = question.answer.subLines.map { String(repeating: "\t", count: $0.indentLevel) + $0.text }.joined(separator: "\n")

                        if isThisEditView {
                            vm.updateQuestion(categoryID: meCategoryID, questionID: question.id, newText: combinedText)
                        } else {
                            let parsedSubLines = vm.parseTextToSubLines(combinedText)
                            question.answer.subLines = parsedSubLines
                            vm.addQuestion(categoryID: meCategoryID, newQuestion: question)
                        }
                        dismiss()
                    }
                } label: {
                    Text("완료")
                        .font(.system(size: 20, weight: .bold))
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
                        .font(.system(size: 17, weight: .bold))
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
            .background(Color.gray.opacity(0.1))
            .cornerRadius(25)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .shadow(
                color: .black.opacity(0.1),
                radius: 8,
                x: 0, y: 3
            )
        }
    }

    private func ContentEditView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("질문을 입력하세요.", text: $question.headLine)
                .font(.system(size: 16, weight: .heavy))
                .focused($isKeyBoardOn)
                .padding(.horizontal, 6)
            
            renderAnswer(answer: $question.answer)  
        }
        .whiteBoxWithShadow(lineSpacing: 0)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func combineSubLines(_ subLines: [SubLineModel]) -> String {
        var combinedText = ""
        
        func addSubLineText(_ subLines: [SubLineModel], indentLevel: Int) {
            for subLine in subLines {
                let indent = String(repeating: "\t", count: indentLevel)
                combinedText += "\(indent)\(subLine.text)\n"
                addSubLineText(subLine.subLines, indentLevel: indentLevel + 1)
            }
        }

        addSubLineText(subLines, indentLevel: 0)
        return combinedText
    }

    private func parseTextToSubLines(_ text: String) -> [SubLineModel] {
        let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
        var stack: [(indentLevel: Int, subLine: SubLineModel)] = []
        
        for line in lines {
            let indentLevel = line.prefix(while: { $0 == "\t" }).count
            let trimmedText = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let newSubLine = SubLineModel(
                id: UUID(),
                text: trimmedText,
                indentLevel: indentLevel,
                listStyle: .none,
                isChecked: false,
                subLines: []
            )
            
            while let last = stack.last, last.indentLevel >= indentLevel {
                stack.removeLast()
            }
            
            if var last = stack.popLast() {  // 🔄 popLast()를 사용하여 마지막 항목을 변수로 꺼냄
                last.subLine.subLines.append(newSubLine)  // 변경 가능
                stack.append(last)  // 수정된 값을 다시 스택에 추가
            } else {
                stack.append((indentLevel, newSubLine))
            }
            
            stack.append((indentLevel, newSubLine))
        }
        
        return stack.first?.subLine.subLines ?? []
    }

    private func renderAnswer(answer: Binding<AnswerModel>) -> AnyView {
        return AnyView(
            CusTextEditorView(
                viewModel: vm,
                text: Binding(
                    get: { combineSubLines(question.answer.subLines) },
                    set: { newValue in
                        question.answer.subLines = parseTextToSubLines(newValue)
                    }
                ),
                categoryID: meCategoryID,
                questionID: question.id,
                answerID: question.answer.id
            )
        )
    }
}

#Preview {
    if let firstCategory = mockData_meCategoryModelList.first,
       let firstQuestion = firstCategory.questionModelList.first {
        let mockViewModel = MeViewModel(
            meCategoryModelList: mockData_meCategoryModelList,
            profile: mockData_profile
        )
        return EditQuestionView(
            vm: mockViewModel,
            meCategoryID: firstCategory.id,
            question: firstQuestion
        )
    } else {
        return Text("Mock 데이터가 비어 있습니다.")
    }
}
