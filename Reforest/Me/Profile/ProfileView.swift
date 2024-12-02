import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm: MeViewModel
    
    @State private var profile: ProfileModel
    @State private var isShowEmptyAlert: Bool = false
    @State private var isOpenPhotoView: Bool = false
    
    init(vm: MeViewModel) {
        self.vm = vm
        self._profile = State(initialValue: vm.profile)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationView()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ProfileView()
                    NameView()
                    ValueView()
                }
            }
            .padding(.horizontal, 20)
        }
        .alert(isPresented: $isShowEmptyAlert) {
            Alert(title: Text("내용을 모두 입력해주세요"), dismissButton: .default(Text("확인")))
        }
        .sheet(isPresented: $isOpenPhotoView) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$profile.profileImage)
        }
    }
}

extension ProfileView {
    private func NavigationView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("취소")
                    .foregroundStyle(.gray)
                    .font(Font.system(size: 20, weight: .bold))
                    .onTapGesture {
                        dismiss()
                    }
                Spacer()
                Text("프로필 편집")
                    .font(Font.system(size: 22, weight: .bold))
                Spacer()
                Button {
                    if profile.name.isEmpty || profile.value.isEmpty {
                        isShowEmptyAlert = true
                    } else {
                        vm.saveProfile(profile: profile)
                        dismiss()
                    }
                } label: {
                    Text("완료")
                        .font(Font.system(size: 20, weight: .bold))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
            Divider()
        }
    }
    
    private func ProfileView() -> some View {
        VStack(spacing: 0) {
            if let profileImage = profile.profileImage {
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
            Menu {
                Button(action: {
                    checkPhotoLibraryPermission()
                }) {
                    Label("라이브러리에서 선택", systemImage: "photo")
                }
                Button(action: {
                    profile.profileImage = nil
                }) {
                    Label("현재 이미지 삭제", systemImage: "trash")
                }
            } label: {
                Text("사진 수정")
                    .font(Font.system(size: 17, weight: .bold))
                    .padding(.top, 10)
            }
        }
        .padding(.top, 20)
    }
    
    private func NameView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("이름")
                .font(Font.system(size: 22, weight: .bold))
                .padding(.bottom, 20)
            TextField("이름을 입력하세요.", text: $profile.name)
                .tint(.black)
                .font(Font.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .whiteBoxWithShadow(lineSpacing: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 15)
    }
    
    private func ValueView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("가치관")
                .font(Font.system(size: 22, weight: .bold))
                .padding(.bottom, 20)
            TextEditor(text: $profile.value)
                .scrollContentBackground(.hidden)
                .padding()
                .tint(.black)
                .font(Font.system(size: 16))
                .frame(height: 100)
                .foregroundColor(.black.opacity(0.6))
                .background(.lightYellow)
                .cornerRadius(10)
                .lineSpacing(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    DispatchQueue.main.async {
                        isOpenPhotoView = true
                    }
                }
            }
        case .authorized, .limited:
            isOpenPhotoView = true
        default:
            // 권한이 없을 때 처리
            print("사진 접근 권한이 필요합니다.")
        }
    }
}
