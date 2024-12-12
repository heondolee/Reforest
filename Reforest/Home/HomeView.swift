//
//  HomeView.swift
//  Reforest
//
//  Created by Heondo Lee on 12/3/24.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var vm: MeViewModel // ViewModel 선언
    
    init() {
        let meCategoryModelList = UserDefaultKey.getObjectFromDevice(key: .meCategoryModelList, [MeCategoryModel].self) ?? []
        let profileName = UserDefaultKey.getValueFromDevice(key: .profileName, String.self) ?? ""
        let profileValue = UserDefaultKey.getValueFromDevice(key: .profileValue, String.self) ?? ""
        let profileImage = UserDefaultKey.getValueFromDevice(key: .profileImage, Data.self) ?? Data()
        let profile = ProfileModel(name: profileName, profileImage: UIImage(data: profileImage), value: profileValue)
        
        self._vm = StateObject(wrappedValue: MeViewModel(meCategoryModelList: meCategoryModelList, profile: profile))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopView()
            profile()
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    Image("Me")
                        .resizable()
                        .scaledToFill()
                }
            }
        }
    }
}

extension HomeView {
    private func TopView() -> some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Image(.homeLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 43)
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
                Text(vm.profile.name.isEmpty ? "이름" : vm.profile.name)
                    .font(Font.system(size: 15, weight: .bold))
                    .opacity(vm.profile.name.isEmpty ? 0.5 : 1.0) // 흐림 효과
                    .padding(.top, 15)
            }
            .padding(.trailing, 20)
            Text(vm.profile.value)
                .padding(15)
                .frame(maxWidth: .infinity, maxHeight: 96, alignment: .topLeading)
                .background(.yellow.opacity(0.3))
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }
}

#Preview {
    HomeView()
}
