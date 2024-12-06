//
//  MeViewModel.swift
//  Reforest
//
//  Created by 헌도리 on 11/28/24.
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

        // 업데이트된 ContentModel 적용
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
}
