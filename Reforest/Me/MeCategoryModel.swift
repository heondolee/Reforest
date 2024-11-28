//
//  MeCategoryModel.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import Foundation

struct MeCategoryModel: Hashable, Codable {
    let id: UUID
    var title: String
    var contentList: [ContentModel]
}

struct ContentModel: Hashable, Identifiable, Codable {
    let id: UUID
    var headLine: String
    var subLine: SubLineModel
}

struct SubLineModel: Hashable, Codable {
    let id: UUID
    var text: String
}
