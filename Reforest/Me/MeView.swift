//
//  MeView.swift
//  Reforest
//
//  Created by 가은리 on 11/28/24.
//

import SwiftUI

struct MeView: View {
    
    @StateObject private var vm: MeViewModel
    
    @State private var selectedContent: ContentModel? = nil
    @State private var isShowAddingContentView: Bool = false
    @State private var selectedMeCategory: MeCategoryModel?
    
    init() {
        // FIXME: 수정해야 함
        let meCategoryModelList = mockData_meCategoryModelList
        let profile = mockData_profile
        self._vm = StateObject(wrappedValue: MeViewModel(meCategoryModelList: meCategoryModelList, profile: profile))
        self.selectedContent = selectedContent
        self.isShowAddingContentView = isShowAddingContentView
        self.selectedMeCategory = meCategoryModelList.first
    }
    
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
        .fullScreenCover(item: $selectedContent, content: { selectedContent in
            if let selectedMeCategoryModelId = selectedMeCategory?.id {
                EditQuestionView(vm: vm, meCategoryID: selectedMeCategoryModelId, content: selectedContent)
            }
        })
        .fullScreenCover(isPresented: $isShowAddingContentView, content: {
            if let selectedMeCategoryModelId = selectedMeCategory?.id {
                EditQuestionView(vm: vm, meCategoryID: selectedMeCategoryModelId, content: selectedContent)
            } else {
                Text("dd")
            }
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
                    .background(.tertiary.opacity(0.2))
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
                        let isSelected = selectedMeCategory?.id == meCategory.id
                        Text(meCategory.title)
                            .font(Font.system(size: 17, weight: .bold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(isSelected ? .white : .clear)
                            .cornerRadius(100)
                            .onTapGesture {
                                selectedMeCategory = meCategory
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
    @ViewBuilder
    private func meCategoryContentList() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: .zero) {
                Spacer()
                Image(systemName: "plus.app")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .padding(.top, 20)
                    .onTapGesture {
                        isShowAddingContentView = true
                    }
                    .padding(.trailing, 25)
            }
            if let selectedMeCategory = selectedMeCategory,
               !selectedMeCategory.contentList.isEmpty {
                ScrollView(showsIndicators: false) {
                    ForEach(selectedMeCategory.contentList, id: \.self) { content in
                        meCategoryContentBox(meCategory: selectedMeCategory, content)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    Text("나에 대해 작성해보세요")
                        .padding(.horizontal, 20)
                    Spacer()
                    Spacer()
                }
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
    private func meCategoryContentBox(meCategory: MeCategoryModel, _ content: ContentModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(content.headLine)
                    .font(Font.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                Spacer()
                Menu {
                    Button {
                        selectedMeCategory = meCategory
                        selectedContent = content
                    } label: {
                        Label("수정", systemImage: "pencil")
                    }
                    
                    Button {
                        vm.removeContent(by: content.id)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 26, height: 26)
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom, 8)
            VStack(spacing: 5) {
                HStack(spacing: 0) {
                    Image(.arrow)
                        .frame(width: 24, height: 24)
                    Text(content.subLine.text)
                        .font(Font.system(size: 14))
                        .lineLimit(2)
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
