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
    @Published var selectedMeCategoryIndex: Int?
    @Published var isShowProfileView: Bool = false
    
    init() {
        //FIXME: 수정해야 함
        self.meCategoryModelList = [
            MeCategoryModel(id: UUID(), title: "성격", contentList: [ContentModel(id: UUID(), headLine: "나의 장점", subLine: SubLineModel(id: UUID(), text: "신중하고 남의 공감을 잘함"))]),
            MeCategoryModel(id: UUID(), title: "경험", contentList: []),
            MeCategoryModel(id: UUID(), title: "인생", contentList: []),
            MeCategoryModel(id: UUID(), title: "취미", contentList: [])
        ]
        self.profile = ProfileModel(name: "이헌도", profileImage: nil, value: "Do not go gentle into that good night, Old age should burn and rave at close of day.")
        if meCategoryModelList.isEmpty {
            self.selectedMeCategoryIndex = nil
        } else {
            self.selectedMeCategoryIndex = 0
        }
    }
    
    func saveProfile(profile: ProfileModel) {
        self.profile = profile
    }
    
    func getMeCategoryIndex(_ meCategory: MeCategoryModel) -> Int? {
        meCategoryModelList.firstIndex(of: meCategory)
    }
    
    func removeContent(by contentId: UUID) {
        meCategoryModelList = meCategoryModelList.map { category in
            var updatedCategory = category
            updatedCategory.contentList = category.contentList.filter { $0.id != contentId }
            return updatedCategory
        }
    }
    
    func updateSubLineText(editContent: ContentModel) {
        for (categoryIndex, category) in meCategoryModelList.enumerated() {
            for (contentIndex, content) in category.contentList.enumerated() {
                if content.id == editContent.id {
                    meCategoryModelList[categoryIndex].contentList[contentIndex].headLine = editContent.headLine
                    meCategoryModelList[categoryIndex].contentList[contentIndex].subLine.text = editContent.subLine.text
                    return
                }
            }
        }
    }
}
