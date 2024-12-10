import SwiftUI

struct SocialView: View {
    @State private var items: [ListItem] = [
        ListItem(title: "1. 신중하고 공감을 잘함", children: [
            ListItem(title: "신중하고 공감을 잘함", children: [
                ListItem(title: "신중하고 공감을 잘함"),
            ]),
            ListItem(title: "신중하고 공감을 잘함")
        ]),
        ListItem(title: "2. 신중하고 공감을 잘함", children: [
            ListItem(title: "신중하고 공감을 잘함"),
        ])
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(items) { item in
                    ListRowView(item: item, depth: 0)
                }
            }
            .padding()
        }
    }
}

struct ListRowView: View {
    var item: ListItem
    var depth: Int
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // 자식이 있을 때만 화살표 버튼 표시
                if !item.children.isEmpty {
                    Button(action: {
                        isExpanded.toggle()
                    }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .frame(width: 20)
                            .padding(.leading, CGFloat(depth) * 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // 화살표 버튼이 없을 때 여백을 맞추기 위한 빈 공간
                    Spacer()
                        .frame(width: 20)
                        .padding(.leading, CGFloat(depth) * 25)
                }

                // 제목 텍스트
                Text(item.title)
            }

            // 펼쳤을 때만 선과 자식 노드를 표시
            if isExpanded {
                HStack(alignment: .top) {
                    // 선을 위한 뷰
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(.gray)
                        .padding(.leading, CGFloat(depth) * 16 + 10)
                        .padding(.top, 4)

                    // 자식 노드들
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(item.children) { child in
                            ListRowView(item: child, depth: depth + 1)
                        }
                    }
                }
            }
        }
    }
}

struct ListItem: Identifiable {
    let id = UUID()
    let title: String
    var children: [ListItem] = []
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
    }
}
