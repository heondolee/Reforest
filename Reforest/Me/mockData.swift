//
//  mockData.swift
//  Reforest
//
//  Created by 가은리 on 11/29/24.
//

import Foundation

let mockData_meCategoryModelList = [
    MeCategoryModel(id: UUID(), title: "성격", contentList: [ContentModel(id: UUID(), headLine: "나의 장점", subLine: SubLineModel(id: UUID(), text: "신중하고 남의 공감을 잘함"))]),
    MeCategoryModel(id: UUID(), title: "경험", contentList: []),
    MeCategoryModel(id: UUID(), title: "인생", contentList: []),
    MeCategoryModel(id: UUID(), title: "취미", contentList: [])
]
let mockData_profile = ProfileModel(name: "이헌도", profileImage: nil, value: "Do not go gentle into that good night, Old age should burn and rave at close of day.")
