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
                        if isThisEditView {
                            vm.updateQuestion(categoryID: meCategoryID, editQuestion: question)
                        } else {
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
    VStack(alignment: .leading, spacing: 6) {
        TextField("질문을 입력하세요.", text: $question.headLine)
            .font(.system(size: 16, weight: .heavy))
            .focused($isKeyBoardOn)
            .padding(.horizontal, 6)
        
        VStack(alignment: .leading, spacing: 8) {
            renderAnswer(answer: $question.answer)  // 💖 renderSubLine 대신 renderAnswer 호출
        }
        .padding(.horizontal, 10)
    }
    .whiteBoxWithShadow(lineSpacing: 8)
    .padding(.horizontal, 20)
}

    private func renderAnswer(answer: Binding<AnswerModel>) -> AnyView {
        let answerID = answer.wrappedValue.id  // 💖 answerID 사용

        return AnyView(
            CusTextEditorView(
                viewModel: vm,
                text: Binding(
                    get: { answer.wrappedValue.subLines.first?.text ?? "" },
                    set: { newValue in
                        if !answer.wrappedValue.subLines.isEmpty {
                            answer.wrappedValue.subLines[0].text = newValue  // 💖 첫 번째 요소의 text를 수정
                        }
                    }
                ),
                categoryID: meCategoryID,
                questionID: question.id,  // 💖 contentID → questionID로 변경
                answerID: answerID
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
