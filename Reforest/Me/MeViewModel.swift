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
    @Published var isShowProfileView: Bool = false
    
    init(meCategoryModelList: [MeCategoryModel], profile: ProfileModel) {
        self.meCategoryModelList = meCategoryModelList
        self.profile = profile
    }
    
    func saveProfile(profile: ProfileModel) {
        self.profile = profile
    }
    
    func getMeCategoryIndex(_ meCategory: MeCategoryModel) -> Int? {
        meCategoryModelList.firstIndex(of: meCategory)
    }
    
    func getUpdatedMeCategory(_ meCategory: MeCategoryModel) -> MeCategoryModel? {
        if let meCategory = meCategoryModelList.first(where: { $0.id == meCategory.id }) {
            return meCategory
        }
        return nil
    }
    
    func removeContent(by contentId: UUID) {
        meCategoryModelList = meCategoryModelList.map { category in
            var updatedCategory = category
            updatedCategory.contentList = category.contentList.filter { $0.id != contentId }
            return updatedCategory
        }
    }
    
    func updateContent(MeCategoryID: UUID, editContent: ContentModel) {
        for (categoryIndex, category) in meCategoryModelList.enumerated() {
            if category.id == MeCategoryID {
                for (contentIndex, content) in category.contentList.enumerated() {
                    if content.id == editContent.id {
                        // headLine 업데이트
                        self.meCategoryModelList[categoryIndex].contentList[contentIndex].headLine = editContent.headLine

                        // subLines 업데이트
                        for (subLineIndex, subLine) in content.subLines.enumerated() {
                            if let editSubLine = editContent.subLines.first(where: { $0.id == subLine.id }) {
                                self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines[subLineIndex].text = editSubLine.text
                                self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines[subLineIndex].indentLevel = editSubLine.indentLevel
                                self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines[subLineIndex].listStyle = editSubLine.listStyle
                            }
                        }
                        return
                    }
                }
            }
        }
    }

    
    func addContent(MeCategoryID: UUID, addContent: ContentModel) {
        for (categoryIndex, category) in meCategoryModelList.enumerated() {
            if category.id == MeCategoryID {
                self.meCategoryModelList[categoryIndex].contentList.append(addContent)
                return
            }
        }
    }
}
