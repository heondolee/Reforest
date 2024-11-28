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
    @Published var selectedMeCategory: MeCategoryModel?
    @Published var isShowProfileView: Bool = false
    
    init() {
        //FIXME: 수정해야 함
        self.meCategoryModelList = [
            MeCategoryModel(title: "성격", contentList: [MeCategoryContentModel(headLine: "나의 장점", subLineList: ["신중하고 남의 공감을 잘함",  "신중하고 남의 공감을 잘함"])]),
            MeCategoryModel(title: "경험", contentList: []),
            MeCategoryModel(title: "인생", contentList: []),
            MeCategoryModel(title: "취미", contentList: [])
        ]
        self.profile = ProfileModel(name: "이헌도", profileImage: nil, value: "Do not go gentle into that good night, Old age should burn and rave at close of day.")
        self.selectedMeCategory = meCategoryModelList.first
    }
    
    func saveProfile(profile: ProfileModel) {
        self.profile = profile
    }
}
