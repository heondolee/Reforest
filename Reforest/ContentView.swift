//
//  ContentView.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import SwiftUI

struct MeCategoryModel: Hashable {
    let title: String
    let contentList: [MeCategoryContentModel]
}

struct MeCategoryContentModel: Hashable {
    let headLine: String
    let subLineList: [String]
}

extension View {
    func whiteBoxWithShadow(padding: (horizontal: CGFloat, vertical: CGFloat) = (20, 20), lineSpacing: CGFloat) -> some View {
        self
            .padding(.horizontal, padding.horizontal)
            .padding(.vertical, padding.vertical)
            .frame(maxWidth: .infinity)
            .background(.white)
            .lineSpacing(lineSpacing)
            .cornerRadius(12)
            .shadow(
                color: .black.opacity(0.1),
                radius: CGFloat(15),
                x: CGFloat(0), y: CGFloat(3)
            )
    }
}

class ContentViewModel: ObservableObject {
    @Published var meCategoryModelList: [MeCategoryModel]
    @Published var profileImage: UIImage?
    @Published var selectedMeCategory: MeCategoryModel?
    
    init() {
        //FIXME: 수정해야 함
        self.meCategoryModelList = [
            MeCategoryModel(title: "성격", contentList: [MeCategoryContentModel(headLine: "나의 장점", subLineList: ["신중하고 남의 공감을 잘함",  "신중하고 남의 공감을 잘함"])]),
            MeCategoryModel(title: "경험", contentList: []),
            MeCategoryModel(title: "인생", contentList: []),
            MeCategoryModel(title: "취미", contentList: [])
        ]
        self.profileImage = nil
        self.selectedMeCategory = meCategoryModelList.first
    }
}

struct ContentView: View {
    @State private var isOpenPhotoView: Bool = false
    
    @StateObject private var vm: ContentViewModel = ContentViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            navigationView()
            profile()
            profileButtons()
            meCategory()
            meCategoryContentList()
        }
        .sheet(isPresented: $isOpenPhotoView) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$vm.profileImage)
        }
    }
}

extension ContentView {
    private func navigationView() -> some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Text("나")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "plus")
                    .frame(width: 18, height: 18)
                    .padding(10)
                    .background(.tertiary.opacity(0.12))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 13)
            Divider()
                .padding(.bottom, 20)
        }
    }
    private func profile() -> some View {
        HStack(alignment: .top, spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                if let profileImage = vm.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 97, height: 97)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 74, height: 70)
                        .padding(.top, 27)
                        .padding(.horizontal, 12)
                        .background(.tertiary.opacity(0.12))
                        .clipShape(Circle())
                }
                Text("이헌도")
                    .font(Font.system(size: 15, weight: .bold))
                    .padding(.top, 10)
            }
            .padding(.trailing, 20)
            Text("Do ")
                .padding(15)
                .frame(maxWidth: .infinity, maxHeight: 96)
                .background(.lightYellow)
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }
    private func profileButtons() -> some View {
        HStack(spacing: .zero) {
            strokeBox(image: .gift, title: "추천")
                .padding(.trailing, 10)
            strokeBox(title: "템플릿")
            Spacer()
            strokeBox(title: "프로필 편집")
                .onTapGesture {
                    // 추가해야 함
                }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    private func meCategory() -> some View {
        HStack(spacing: .zero) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .zero) {
                    ForEach(vm.meCategoryModelList, id: \.self) { meCategory in
                        let isSelected = vm.selectedMeCategory == meCategory
                        Text(meCategory.title)
                            .font(Font.system(size: 17, weight: .bold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(isSelected ? .white : .clear)
                            .cornerRadius(100)
                            .onTapGesture {
                                vm.selectedMeCategory = meCategory
                            }
                    }
                }
            }
            Image(systemName: "ellipsis")
                .padding(.trailing)
                .frame(width: 26, height: 26)
                .onTapGesture {
                    // 추가해야 함
                }
        }
        .padding(8)
        .background(.grayA6.opacity(0.1))
        .cornerRadius(25)
        .padding(.horizontal, 20)
    }
    private func meCategoryContentList() -> some View {
        ScrollView(showsIndicators: false) {
            if let meCategory = vm.selectedMeCategory {
                ForEach(meCategory.contentList, id: \.self) { content in
                    meCategoryContentBox(content)
                }
            } else {
                Spacer()
                Text("나에 대해 작성해보세요")
                    .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}

extension ContentView {
    private func strokeBox(image: ImageResource? = nil, title: String) -> some View {
        HStack(spacing: 0) {
            if let image {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 16, height: 16)
                    .padding(.trailing, 5)
            }
            Text(title)
                .font(Font.system(size: 14, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white)
        .cornerRadius(8)
        .padding(1)
        .background(.gray)
        .cornerRadius(9)
    }
    private func meCategoryContentBox(_ content: MeCategoryContentModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(content.headLine)
                    .font(Font.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "ellipsis")
                    .frame(width: 26, height: 26)
                    .onTapGesture {
                        // 추가해야 함
                    }
            }
            .padding(.bottom, 8)
            VStack(spacing: 5) {
                ForEach(content.subLineList, id: \.self) { subLine in
            HStack(spacing: 0) {
                Image(.arrow)
                    .frame(width: 24, height: 24)
                        Text(subLine)
                            .font(Font.system(size: 14))
                            .lineLimit(2)
                    }
                }
            }
        }
        .whiteBoxWithShadow(lineSpacing: 8)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

#Preview {
    ContentView()
}
