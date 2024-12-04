//
//  MeViewModel.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

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

        // headLine 업데이트
        self.meCategoryModelList[categoryIndex].contentList[contentIndex].headLine = editContent.headLine

        // subLines 업데이트
        let updatedSubLines = editContent.subLines.reduce(into: [:]) { $0[$1.id] = $1 }
        for (index, subLine) in self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines.enumerated() {
            if let updatedSubLine = updatedSubLines[subLine.id] {
                self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines[index] = updatedSubLine
            }
        }
    }

    func addContent(MeCategoryID: UUID, addContent: ContentModel) {
        if let categoryIndex = meCategoryModelList.firstIndex(where: { $0.id == MeCategoryID }) {
            self.meCategoryModelList[categoryIndex].contentList.append(addContent)
        }
    }
}
