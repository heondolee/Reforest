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
        List(items, children: \.children) { item in
            HStack {
                Text(item.title)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ListItem: Identifiable {
    let id = UUID()
    let title: String
    var children: [ListItem]? = nil
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
    }
}
