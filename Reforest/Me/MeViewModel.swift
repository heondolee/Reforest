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
                        self.meCategoryModelList[categoryIndex].contentList[contentIndex].headLine = editContent.headLine
                        self.meCategoryModelList[categoryIndex].contentList[contentIndex].subLine.text = editContent.subLine.text
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
