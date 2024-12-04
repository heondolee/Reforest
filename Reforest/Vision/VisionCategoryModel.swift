//
//  ViewCategoryModel.swift
//  Reforest
//
//  Created by Heondo Lee on 12/3/24.
//

import Foundation

struct VisionCategoryModel: Hashable, Codable {
    let id: UUID
    var title: String
    var contentList: [ContentModel]
}

struct VisionContentModel: Hashable, Identifiable, Codable {
    let id: UUID
    var headLine: String
    var subLine: SubLineModel
}

struct VisionSubLineModel: Hashable, Codable {
    let id: UUID
    var text: String
}
