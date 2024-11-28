//
//  MeView.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import SwiftUI

struct MeView: View {
    
    @StateObject private var vm: MeViewModel = MeViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            navigationView()
            profile()
            profileButtons()
            meCategory()
            meCategoryContentList()
        }
        .fullScreenCover(isPresented: $vm.isShowProfileView, content: {
            ProfileView(vm: vm)
        })
    }
}

extension MeView {
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
                if let profileImage = vm.profile.profileImage {
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
                Text(vm.profile.name)
                    .font(Font.system(size: 15, weight: .bold))
                    .padding(.top, 10)
            }
            .padding(.trailing, 20)
            Text(vm.profile.value)
                .padding(15)
                .frame(maxWidth: .infinity, maxHeight: 96, alignment: .topLeading)
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
                    vm.isShowProfileView = true
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

extension MeView {
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
    MeView()
}
