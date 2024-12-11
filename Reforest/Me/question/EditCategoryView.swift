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
            NavigationHeaderView()
            ListView()
        }
        .alert(isPresented: $isShowEmptyAlert) {
            Alert(title: Text("내용을 모두 입력해주세요"), dismissButton: .default(Text("확인")))
        }
    }
}

extension EditCategoryView {
    private func NavigationHeaderView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("나 - 카테고리 수정하기")
                    .font(Font.system(size: 22, weight: .bold))
                Spacer()
                Text("취소")
                    .foregroundColor(.gray)
                    .font(Font.system(size: 20, weight: .bold))
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(.trailing, 30)
                Button {
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
                            meCategoryModelList.append(MeCategoryModel(id: UUID(), title: editText, questionModelList: []))
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
                                .padding(.leading, 16)
                            
                            Spacer()
                            
                            Button(action: {
                                deleteItem(meCategory: meCategory)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 16)
                        }
                        .padding(.vertical, 14.0)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        )
                        .padding(.horizontal, 8)
                        .listRowSeparator(.hidden)
                    }
                    .onMove(perform: moveItem)
                }
                .listStyle(PlainListStyle())
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
