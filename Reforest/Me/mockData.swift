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
                        listStyle: .checkbox, // 체크박스 스타일
                        isChecked: true, // 체크 상태
                        subLines: [
                            SubLineModel(
                                id: UUID(),
                                text: "듣기 능력이 뛰어남",
                                indentLevel: 1,
                                listStyle: .bulleted,
                                isChecked: false, // 체크되지 않음
                                subLines: []
                            ),
                            SubLineModel(
                                id: UUID(),
                                text: "다양한 의견을 포용함",
                                indentLevel: 1,
                                listStyle: .bulleted,
                                isChecked: true, // 체크됨
                                subLines: []
                            )
                        ]
                    ),
                    SubLineModel(
                        id: UUID(),
                        text: "항상 긍정적인 마인드를 가짐",
                        indentLevel: 0,
                        listStyle: .checkbox,
                        isChecked: false, // 체크되지 않음
                        subLines: [
                            SubLineModel(
                                id: UUID(),
                                text: "긍정적인 사고로 어려움을 극복함",
                                indentLevel: 1,
                                listStyle: .numbered,
                                isChecked: true, // 체크됨
                                subLines: []
                            )
                        ]
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
                        listStyle: .checkbox, // 체크박스 스타일
                        isChecked: true, // 체크 상태
                        subLines: [
                            SubLineModel(
                                id: UUID(),
                                text: "결정이 늦어지는 경우가 종종 있음",
                                indentLevel: 1,
                                listStyle: .none,
                                isChecked: false, // 체크되지 않음
                                subLines: []
                            )
                        ]
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
                        listStyle: .checkbox,
                        isChecked: true, // 체크 상태
                        subLines: [
                            SubLineModel(
                                id: UUID(),
                                text: "아이들을 가르치며 보람을 느낌",
                                indentLevel: 1,
                                listStyle: .bulleted,
                                isChecked: false, // 체크되지 않음
                                subLines: []
                            )
                        ]
                    )
                ]
            )
        ]
    )
    // 나머지 카테고리도 동일한 방식으로 수정
]

let mockData_profile = ProfileModel(
    name: "이헌도",
    profileImage: nil,
    value: "Do not go gentle into that good night, Old age should burn and rave at close of day."
)
