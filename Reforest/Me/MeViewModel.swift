import Foundation

class MeViewModel: ObservableObject {
    @Published var meCategoryModelList: [MeCategoryModel]
    @Published var profile: ProfileModel
    @Published var selectedCategory: MeCategoryModel
    @Published var isShowProfileView: Bool = false
    
    init(meCategoryModelList: [MeCategoryModel], profile: ProfileModel) {
        self.meCategoryModelList = meCategoryModelList
        self.profile = profile
        self.selectedCategory = meCategoryModelList.first ?? MeCategoryModel(id: UUID(), title: "Default", contentList: [])
    }
    
    func saveProfile(profile: ProfileModel) {
        self.profile = profile
    }
    
    func getUpdatedMeCategory(_ meCategory: MeCategoryModel) -> MeCategoryModel? {
        meCategoryModelList.first(where: { $0.id == meCategory.id })
    }
    
    func removeContent(by contentId: UUID) {
        for (categoryIndex, category) in meCategoryModelList.enumerated() {
            if let contentIndex = category.contentList.firstIndex(where: { $0.id == contentId }) {
                self.meCategoryModelList[categoryIndex].contentList.remove(at: contentIndex)
                return
            }
        }
    }
    
    func updateContent(MeCategoryID: UUID, editContent: ContentModel) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == MeCategoryID }),
              let contentIndex = meCategoryModelList[categoryIndex].contentList.firstIndex(where: { $0.id == editContent.id }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].contentList[contentIndex] = editContent
    }

    func addContent(MeCategoryID: UUID, addContent: ContentModel) {
        if let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == MeCategoryID }) {
            self.meCategoryModelList[categoryIndex].contentList.append(addContent)
        }
    }
    
    // SubLineModel 관련 메서드 추가
    func addSubLine(to contentID: UUID, in categoryID: UUID, subLine: SubLineModel) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let contentIndex = meCategoryModelList[categoryIndex].contentList.firstIndex(where: { $0.id == contentID }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines.append(subLine)
    }
    
    func updateSubLine(in contentID: UUID, categoryID: UUID, subLine: SubLineModel) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let contentIndex = meCategoryModelList[categoryIndex].contentList.firstIndex(where: { $0.id == contentID }),
              let subLineIndex = meCategoryModelList[categoryIndex].contentList[contentIndex].subLines.firstIndex(where: { $0.id == subLine.id }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines[subLineIndex] = subLine
    }

    func removeSubLine(from contentID: UUID, in categoryID: UUID, subLineID: UUID) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let contentIndex = meCategoryModelList[categoryIndex].contentList.firstIndex(where: { $0.id == contentID }),
              let subLineIndex = meCategoryModelList[categoryIndex].contentList[contentIndex].subLines.firstIndex(where: { $0.id == subLineID }) else {
            return
        }

        self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines.remove(at: subLineIndex)
    }
    
    // 체크박스 상태 토글
    func toggleCheckBox(in contentID: UUID, categoryID: UUID, subLineID: UUID) {
        guard let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
              let contentIndex = meCategoryModelList[categoryIndex].contentList.firstIndex(where: { $0.id == contentID }),
              let subLineIndex = meCategoryModelList[categoryIndex].contentList[contentIndex].subLines.firstIndex(where: { $0.id == subLineID }) else {
            return
        }
        meCategoryModelList[categoryIndex].contentList[contentIndex].subLines[subLineIndex].isChecked.toggle()
    }

    func findSubLine(with text: String, in contentID: UUID, categoryID: UUID) -> SubLineModel? {
    guard let category = meCategoryModelList.first(where: { $0.id == categoryID }),
          let content = category.contentList.first(where: { $0.id == contentID }) else {
        return nil
    }
    
    return content.subLines.first(where: { $0.text == text })
}

}
