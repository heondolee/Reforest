//
//  MeCategoryModel.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import Foundation

enum ListStyle: String, Codable {
    case none
    case checkbox
    case numbered
    case bulleted
}

struct MeCategoryModel: Hashable, Codable {
    let id: UUID
    var title: String
    var contentList: [ContentModel]
}

struct ContentModel: Hashable, Identifiable, Codable {
    let id: UUID
    var headLine: String
    var subLines: [SubLineModel]
}

struct SubLineModel: Hashable, Codable {
    let id: UUID
    var text: String
    var indentLevel: Int // 들여쓰기 레벨
    var listStyle: ListStyle // 리스트 스타일
}
