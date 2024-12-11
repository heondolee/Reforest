import Foundation

class MeViewModel: ObservableObject {
    @Published var meCategoryModelList: [MeCategoryModel]
    @Published var profile: ProfileModel
    @Published var selectedCategory: MeCategoryModel
    @Published var isShowProfileView: Bool = false
    
    init(meCategoryModelList: [MeCategoryModel], profile: ProfileModel) {
        self.meCategoryModelList = meCategoryModelList
        self.profile = profile
        self.selectedCategory = meCategoryModelList.first ?? MeCategoryModel(id: UUID(), title: "Default", questionModelList: [])
    }
    
    func saveProfile(profile: ProfileModel) {
        self.profile = profile
    }
    
    func getUpdatedMeCategory(_ meCategory: MeCategoryModel) -> MeCategoryModel? {
        meCategoryModelList.first(where: { $0.id == meCategory.id })
    }
    
    func removeQuestion(by questionId: UUID) {
        for (categoryIndex, category) in meCategoryModelList.enumerated() {
            if let questionIndex = category.questionModelList.firstIndex(where: { $0.id == questionId }) {
                self.meCategoryModelList[categoryIndex].questionModelList.remove(at: questionIndex)
                return
            }
        }
    }
    
    func updateQuestion(categoryID: UUID, editQuestion: QuestionModel) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let questionIndex = meCategoryModelList[categoryIndex].questionModelList.firstIndex(where: { $0.id == editQuestion.id }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].questionModelList[questionIndex] = editQuestion
    }

    func addQuestion(categoryID: UUID, newQuestion: QuestionModel) {
        if let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }) {
            self.meCategoryModelList[categoryIndex].questionModelList.append(newQuestion)
        }
    }
    
    // SubLineModel 관련 메서드 추가
    func addSubLine(to questionID: UUID, in categoryID: UUID, subLine: SubLineModel) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let questionIndex = meCategoryModelList[categoryIndex].questionModelList.firstIndex(where: { $0.id == questionID }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].questionModelList[questionIndex].answer.subLines.append(subLine)
    }
    
    func updateSubLine(in questionID: UUID, categoryID: UUID, subLine: SubLineModel) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let questionIndex = meCategoryModelList[categoryIndex].questionModelList.firstIndex(where: { $0.id == questionID }),
              let subLineIndex = meCategoryModelList[categoryIndex].questionModelList[questionIndex].answer.subLines.firstIndex(where: { $0.id == subLine.id }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].questionModelList[questionIndex].answer.subLines[subLineIndex] = subLine
    }

    func removeSubLine(from questionID: UUID, in categoryID: UUID, subLineID: UUID) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let questionIndex = meCategoryModelList[categoryIndex].questionModelList.firstIndex(where: { $0.id == questionID }),
              let subLineIndex = meCategoryModelList[categoryIndex].questionModelList[questionIndex].answer.subLines.firstIndex(where: { $0.id == subLineID }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].questionModelList[questionIndex].answer.subLines.remove(at: subLineIndex)
    }
    
    // 체크박스 상태 토글
    func toggleCheckBox(in questionID: UUID, categoryID: UUID, subLineID: UUID) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let questionIndex = meCategoryModelList[categoryIndex].questionModelList.firstIndex(where: { $0.id == questionID }),
              let subLineIndex = meCategoryModelList[categoryIndex].questionModelList[questionIndex].answer.subLines.firstIndex(where: { $0.id == subLineID }) else {
            return
        }
        meCategoryModelList[categoryIndex].questionModelList[questionIndex].answer.subLines[subLineIndex].isChecked.toggle()
    }

    func findSubLine(with text: String, in questionID: UUID, categoryID: UUID) -> SubLineModel? {
        guard let category = meCategoryModelList.first(where: { $0.id == categoryID }),
              let question = category.questionModelList.first(where: { $0.id == questionID }) else {
            return nil
        }
    
        return question.answer.subLines.first(where: { $0.text == text })
    }
}
