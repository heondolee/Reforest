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

struct MeCategoryModel: Hashable, Codable, Identifiable {
    let id: UUID
    var title: String
    var questionModelList: [QuestionModel]
}

struct QuestionModel: Hashable, Identifiable, Codable {
    let id: UUID
    var headLine: String
    var answer: AnswerModel
}

struct AnswerModel: Hashable, Codable {
    let id: UUID
    var subLines: [SubLineModel]
}

struct SubLineModel: Hashable, Codable, Identifiable {
    let id: UUID
    var text: String
    var indentLevel: Int // 들여쓰기 레벨
    var listStyle: ListStyle // 리스트 스타일
    var isChecked: Bool // 체크박스 체크 여부
    var subLines: [SubLineModel] // 하위 SubLineModel 리스트
}
