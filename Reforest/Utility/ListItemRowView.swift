//
//  Untitled.swift
//  Reforest
//
//  Created by Heondo Lee on 12/12/24.
//

import SwiftUI

struct ListItemRowView: View {
    var items: [SubLineModel]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(items) { item in
                    ListRowView(item: item, depth: 0)
                }
            }
        }
    }
}

struct ListRowView: View {
    var item: SubLineModel
    var depth: Int
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // 자식이 있을 때만 화살표 버튼 표시
                if !item.subLines.isEmpty {
                    Button(action: {
                        isExpanded.toggle()
                    }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .frame(width: 20)
                            .padding(.leading, depth > 0 ? 16 : 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // 화살표 버튼이 없을 때 여백을 맞추기 위한 빈 공간
                    Spacer()
                        .frame(width: 20)
                        .padding(.leading, depth > 0 ? 25 : 0)
                }

                // 제목 텍스트
                Text(item.text)
            }

            // 펼쳤을 때만 선과 자식 노드를 표시
            if isExpanded {
                HStack(alignment: .top) {
                    // 선을 위한 뷰
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(.gray)
                        .padding(.leading, depth > 0 ? 26 : 10)
                        .padding(.top, 4)

                    // 자식 노드들
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(item.subLines) { child in
                            ListRowView(item: child, depth: depth + 1)
                        }
                    }
                }
            }
        }
    }
}


struct ListItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSubLines = [
            SubLineModel(id: UUID(), text: "Item 1", indentLevel: 0, listStyle: .bulleted, isChecked: false, subLines: [
                SubLineModel(id: UUID(), text: "Subitem 1.1", indentLevel: 1, listStyle: .bulleted, isChecked: false, subLines: [])
            ]),
            SubLineModel(id: UUID(), text: "Item 2", indentLevel: 0, listStyle: .numbered, isChecked: false, subLines: [])
        ]

        ListItemRowView(items: sampleSubLines)
    }
}

