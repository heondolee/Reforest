import SwiftUI

struct SocialView: View {
    @State private var items: [ListItem] = [
        ListItem(title: "1. 신중하고 공감을 잘함", children: [
            ListItem(title: "1.1 공감을 잘함", children: [
                ListItem(title: "1.1.1 배려심이 깊음"),
                ListItem(title: "1.1.2 상대방을 존중함")
            ]),
            ListItem(title: "1.2 신중하게 판단함", children: [
                ListItem(title: "1.2.1 상황을 잘 파악함"),
                ListItem(title: "1.2.2 감정을 절제함", children: [
                    ListItem(title: "1.2.2.1 차분하게 행동함"),
                    ListItem(title: "1.2.2.2 감정에 휘둘리지 않음")
                ])
            ])
        ]),
        ListItem(title: "2. 창의적이고 독창적임", children: [
            ListItem(title: "2.1 새로운 아이디어를 제안함"),
            ListItem(title: "2.2 문제 해결 능력이 뛰어남", children: [
                ListItem(title: "2.2.1 복잡한 문제를 잘 해결함"),
                ListItem(title: "2.2.2 논리적으로 접근함")
            ])
        ]),
        ListItem(title: "3. 리더십이 있음", children: [
            ListItem(title: "3.1 팀을 잘 이끎", children: [
                ListItem(title: "3.1.1 책임감을 가짐"),
                ListItem(title: "3.1.2 목표를 명확히 설정함")
            ]),
            ListItem(title: "3.2 소통을 잘함")
        ]),
        ListItem(title: "4. 긍정적이고 열정적임", children: [
            ListItem(title: "4.1 항상 긍정적인 태도를 유지함"),
            ListItem(title: "4.2 새로운 도전을 즐김")
        ]),
        ListItem(title: "5. 협동적이고 친화적임", children: [
            ListItem(title: "5.1 팀워크를 중시함"),
            ListItem(title: "5.2 갈등을 잘 해결함", children: [
                ListItem(title: "5.2.1 서로의 의견을 존중함"),
                ListItem(title: "5.2.2 중재 역할을 잘함")
            ])
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
                Text(item.title)
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
