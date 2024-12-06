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
    @State private var selectedMeCategory: MeCategoryModel? = nil
    @State private var isShowEditCategoryView: Bool = false
    
    init() {
        let meCategoryModelList = UserDefaultKey.getObjectFromDevice(key: .meCategoryModelList, [MeCategoryModel].self) ?? []
        let profileName = UserDefaultKey.getValueFromDevice(key: .profileName, String.self) ?? ""
        let profileValue = UserDefaultKey.getValueFromDevice(key: .profileValue, String.self) ?? ""
        let profileImage = UserDefaultKey.getValueFromDevice(key: .profileImage, Data.self) ?? Data()
        let profile = ProfileModel(name: profileName, profileImage: UIImage(data: profileImage), value: profileValue)
        self._vm = StateObject(wrappedValue: MeViewModel(meCategoryModelList: meCategoryModelList, profile: profile))
        self.selectedContent = selectedContent
        self.isShowAddingContentView = isShowAddingContentView
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                navigationView()
                profile()
                profileButtons()
                meCategory()
                meCategoryContentList()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification, object: nil)) { _ in
            UserDefaultKey.saveObjectInDevice(key: .meCategoryModelList, content: vm.meCategoryModelList)
            UserDefaultKey.saveValueInDevice(key: .profileName, content: vm.profile.name)
            UserDefaultKey.saveValueInDevice(key: .profileValue, content: vm.profile.value)
            UserDefaultKey.saveValueInDevice(key: .profileImage, content: vm.profile.profileImage?.pngData())
        }
        .onAppear {
            if !vm.meCategoryModelList.isEmpty {
                let selectedMeCategory = vm.meCategoryModelList[0]
                self.selectedMeCategory = selectedMeCategory
            }
            // 사용자가 직접 카테고리를 선택하지 않았다면 디폴트로 첫 번째 카테고리를 선택
            if selectedMeCategory == nil, !vm.meCategoryModelList.isEmpty {
                self.selectedMeCategory = vm.meCategoryModelList.first
            }
        }
        .onChange(of: vm.meCategoryModelList) {
            // 새 카테고리가 추가되었을 때 디폴트로 첫 번째 카테고리를 선택
            if selectedMeCategory == nil, !vm.meCategoryModelList.isEmpty {
                self.selectedMeCategory = vm.meCategoryModelList.first
            }
        }
        .fullScreenCover(isPresented: $vm.isShowProfileView, content: {
            ProfileView(vm: vm)
        })
        .fullScreenCover(item: $selectedContent, content: { selectedContent in
            if let selectedMeCategoryModelId = selectedMeCategory?.id {
                EditQuestionView(vm: vm, meCategoryID: selectedMeCategoryModelId, content: selectedContent)
            }
        })
        .fullScreenCover(isPresented: $isShowEditCategoryView, content: {
            EditCategoryView(vm: vm)
        })
        .fullScreenCover(isPresented: $isShowAddingContentView, content: {
            if let selectedMeCategoryModelId = selectedMeCategory?.id {
                EditQuestionView(vm: vm, meCategoryID: selectedMeCategoryModelId, content: selectedContent)
            } else {
                Text("카테고리가 선택되지 않음.")
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
                Text(vm.profile.name.isEmpty ? "이름" : vm.profile.name)                    .font(Font.system(size: 15, weight: .bold))
                    .padding(.top, 10)
                    .opacity(vm.profile.name.isEmpty ? 0.5 : 1.0) // 흐림 효과
            }
            .padding(.trailing, 20)
            Text(vm.profile.value.isEmpty ? "가치관" : vm.profile.value)
                .padding(15)
                .frame(maxWidth: .infinity, maxHeight: 96, alignment: .topLeading)
                .background(.lightYellow)
                .cornerRadius(12)
                .opacity(vm.profile.value.isEmpty ? 0.5 : 1.0) // 흐림 효과
        }
        .padding(.horizontal, 20)
    }
    private func profileButtons() -> some View {
        HStack(spacing: .zero) {
            Spacer()
            strokeBox(title: "프로필 편집")
                .onTapGesture {
                    vm.isShowProfileView = true
                }
            if !vm.meCategoryModelList.isEmpty {
                Image(.stepper)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        isShowAddingContentView = true
                    }
                    .padding(.leading, 15)
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
            Menu {
                Button {
                    isShowEditCategoryView = true
                } label: {
                    Label("수정", systemImage: "pencil")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 26, height: 26)
                    .foregroundColor(.black)
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
            if let preSelectedMeCategory = selectedMeCategory,
               let selectedMeCategory = vm.getUpdatedMeCategory(preSelectedMeCategory),
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
                        .opacity(0.5) // 흐림 효과
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
                    if let firstSubLine = content.subLines.first {
                        Text(firstSubLine.text)
                            .font(Font.system(size: 14))
                            .lineLimit(2)
                    } else {
                        Text("내용이 없습니다.")
                            .font(Font.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .whiteBoxWithShadow(lineSpacing: 8)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

#Preview {
    MeView()
}
