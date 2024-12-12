import SwiftUI

struct EditQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm: MeViewModel
    
    @State var question: QuestionModel
    @State var isShowEmptyAlert: Bool = false
    
    @FocusState private var isKeyBoardOn: Bool
    
    @FocusState private var focusedIndex: Int?

    @State private var tempText: String = ""  // 임시로 텍스트를 저장할 상태 변수
    
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
                    if question.headLine.isEmpty || tempText.isEmpty {
                        isShowEmptyAlert = true
                    } else {
                        let parsedSubLines = parseTextToSubLines(tempText)  // 임시 텍스트를 파싱
                        question.answer.subLines = parsedSubLines  // 파싱된 결과를 저장

                        if isThisEditView {
                            print("🔧 수정된 질문: \(question)")
                            vm.updateQuestion(categoryID: vm.selectedCategory.id, questionID: question.id, editedQuestion: question)
                        } else {
                            vm.addQuestion(categoryID: vm.selectedCategory.id, newQuestion: question)
                            print("➕ 추가된 질문: \(question)")
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
                        .background(isSelected ? Color.white : Color.clear)
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
        .onAppear {
            // meCategoryID에 맞는 카테고리를 선택
            if let matchingCategory = vm.meCategoryModelList.first(where: { $0.id == meCategoryID }) {
                vm.selectedCategory = matchingCategory
            }
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
        // 메서드 내부에서만 사용할 SubLineModel2 정의
        class SubLineModel2: Identifiable {
            let id: UUID
            var text: String
            var indentLevel: Int
            var listStyle: ListStyle
            var isChecked: Bool
            var subLines: [SubLineModel2]

            init(id: UUID, text: String, indentLevel: Int, listStyle: ListStyle, isChecked: Bool, subLines: [SubLineModel2]) {
                self.id = id
                self.text = text
                self.indentLevel = indentLevel
                self.listStyle = listStyle
                self.isChecked = isChecked
                self.subLines = subLines
            }

            // SubLineModel로 변환하는 메서드
            func toSubLineModel() -> SubLineModel {
                return SubLineModel(
                    id: self.id,
                    text: self.text,
                    indentLevel: self.indentLevel,
                    listStyle: self.listStyle,
                    isChecked: self.isChecked,
                    subLines: self.subLines.map { $0.toSubLineModel() } // 하위 항목도 재귀적으로 변환
                )
            }
        }

        let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }

        var rootSubLines: [SubLineModel2] = []
        var stack: [SubLineModel2] = []

        for (index, line) in lines.enumerated() {
            let indentLevel = line.prefix(while: { $0 == "\t" }).count
            let trimmedText = line.trimmingCharacters(in: .whitespacesAndNewlines)

            let newSubLine = SubLineModel2(
                id: UUID(),
                text: trimmedText,
                indentLevel: indentLevel,
                listStyle: .none,
                isChecked: false,
                subLines: []
            )
            // 스택에서 현재 indentLevel보다 큰 요소들만 제거
            while let last = stack.last, last.indentLevel >= indentLevel {
                stack.removeLast()
            }

            if let parent = stack.last {
                // 부모의 subLines에 현재 라인을 추가
                parent.subLines.append(newSubLine)
            } else {
                // 최상위 레벨이면 rootSubLines에 추가
                rootSubLines.append(newSubLine)
            }

            // 스택에 현재 라인을 추가
            stack.append(newSubLine)
        }
        // SubLineModel2를 SubLineModel로 변환하여 반환
        return rootSubLines.map { $0.toSubLineModel() }
    }


    private func renderAnswer(answer: Binding<AnswerModel>) -> AnyView {
        return AnyView(
            CusTextEditorView(
                viewModel: vm,
                text: Binding(
                    get: {
                        tempText  // 상태를 반환만 함
                    },
                    set: { newValue in
                        tempText = newValue  // 입력된 텍스트를 상태에 저장
                    }
                ),
                categoryID: meCategoryID,
                questionID: question.id,
                answerID: question.answer.id
            )
            .onAppear {
                tempText = combineSubLines(question.answer.subLines)  // 초기 텍스트 설정
            }
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
