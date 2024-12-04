//
//  mockData.swift
//  Reforest
//
//  Created by 가은리 on 11/29/24.
//

import Foundation

// preView를 위한
let mockData_meCategoryModelList = [
    MeCategoryModel(
        id: UUID(),
        title: "성격",
        contentList: [
            ContentModel(
                id: UUID(),
                headLine: "나의 장점",
                subLines: [
                    SubLineModel(
                        id: UUID(),
                        text: "신중하고 남의 공감을 잘함",
                        indentLevel: 0,
                        listStyle: .none
                    ),
                    SubLineModel(
                        id: UUID(),
                        text: "항상 긍정적인 마인드를 가짐",
                        indentLevel: 1,
                        listStyle: .bulleted
                    )
                ]
            ),
            ContentModel(
                id: UUID(),
                headLine: "나의 단점",
                subLines: [
                    SubLineModel(
                        id: UUID(),
                        text: "너무 신중해서 결정을 미룰 때가 있음",
                        indentLevel: 0,
                        listStyle: .numbered
                    )
                ]
            )
        ]
    ),
    MeCategoryModel(
        id: UUID(),
        title: "경험",
        contentList: [
            ContentModel(
                id: UUID(),
                headLine: "특별한 경험",
                subLines: [
                    SubLineModel(
                        id: UUID(),
                        text: "해외 봉사활동을 통해 성장함",
                        indentLevel: 0,
                        listStyle: .numbered
                    ),
                    SubLineModel(
                        id: UUID(),
                        text: "학교 프로젝트에서 리더 역할 수행",
                        indentLevel: 1,
                        listStyle: .bulleted
                    )
                ]
            )
        ]
    ),
    MeCategoryModel(id: UUID(), title: "인생", contentList: []),
    MeCategoryModel(id: UUID(), title: "취미", contentList: [])
]
let mockData_profile = ProfileModel(name: "이헌도", profileImage: nil, value: "Do not go gentle into that good night, Old age should burn and rave at close of day.")
