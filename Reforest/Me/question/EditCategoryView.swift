//
//  EditCategoryView.swift
//  Reforest
//
//  Created by 가은리 on 11/29/24.
//

import SwiftUI

struct EditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm: MeViewModel
    @State var isShowEmptyAlert: Bool = false
    @State var isEditMode: Bool = false
    @State var editText: String = ""
    @State var meCategoryModelList: [MeCategoryModel]
    @State var editMode = EditMode.active
    
    init(vm: MeViewModel) {
        self.vm = vm
        self._meCategoryModelList = State(initialValue: vm.meCategoryModelList)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            NavigationView()
            ListView()
        }
        .alert(isPresented: $isShowEmptyAlert) {
            Alert(title: Text("내용을 모두 입력해주세요"), dismissButton: .default(Text("확인")))
        }
    }
}

extension EditCategoryView {
    private func NavigationView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("나 - 카테고리 수정하기")
                    .font(Font.system(size: 22, weight: .bold))
                Spacer()
                Text("취소")
                    .foregroundStyle(.gray)
                    .font(Font.system(size: 20, weight: .bold))
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(.trailing, 30)
                Button {
                    vm.meCategoryModelList = []
                    vm.meCategoryModelList = meCategoryModelList
                    dismiss()
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
    
    private func ListView() -> some View {
        SwiftUI.NavigationView {
            VStack {
                HStack {
                    if isEditMode {
                        TextField("카테고리를 입력하세요.", text: $editText)
                            .tint(.black)
                            .font(Font.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            editMode = .active
                            isEditMode = false
                            meCategoryModelList.append(MeCategoryModel(id: UUID(), title: editText, contentList: []))
                        } label: {
                            Text("카테고리 추가")
                                .font(Font.system(size: 16, weight: .semibold))
                        }
                    } else {
                        Spacer()
                        Image(systemName: "plus.app")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                editMode = .inactive
                                editText = ""
                                isEditMode = true
                            }
                            .padding(.trailing, 20)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
                List {
                    ForEach(meCategoryModelList, id: \.id) { meCategory in
                        HStack {
                            Text(meCategory.title)
                                .font(Font.system(size: 16, weight: .semibold))
                                .padding(.leading, 16) // 텍스트 왼쪽 여백
                            
                            Spacer() // 텍스트를 왼쪽 정렬
                            
                            // 쓰레기통 버튼을 오른쪽에 배치
                            Button(action: {
                                deleteItem(meCategory: meCategory)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(PlainButtonStyle()) // 버튼 스타일을 기본으로 설정
                            .padding(.trailing, 16) // 버튼 오른쪽 여백
                        }
                        .padding(.vertical, 14.0)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        )
                        .padding(.horizontal, 8) // 각 리스트 항목의 좌우 여백
                        .listRowSeparator(.hidden) // 구분선 제거
                    }
                    .onMove(perform: moveItem)
                }
                .listStyle(PlainListStyle()) // 리스트 스타일 간소화
                .environment(\.editMode, $editMode)
 
            }
        }
    }
}

extension EditCategoryView {
    // 항목 삭제 함수
    private func deleteItem(meCategory: MeCategoryModel) {
        meCategoryModelList.removeAll { $0.id == meCategory.id }
    }
    // 항목을 이동시키는 함수
    private func moveItem(from source: IndexSet, to destination: Int) {
        meCategoryModelList.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    EditCategoryView(vm: MeViewModel(meCategoryModelList: mockData_meCategoryModelList, profile: mockData_profile))
}
