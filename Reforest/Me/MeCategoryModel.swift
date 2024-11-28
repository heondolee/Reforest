//
//  MeCategoryModel.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import Foundation

struct MeCategoryModel: Hashable {
    let title: String
    let contentList: [MeCategoryContentModel]
}

struct MeCategoryContentModel: Hashable {
    let headLine: String
    let subLineList: [String]
}
