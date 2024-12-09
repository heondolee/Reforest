import SwiftUI
import UIKit

struct MarkdownEditorView: UIViewRepresentable {
    @ObservedObject var viewModel: MeViewModel
    var categoryID: UUID
    var contentID: UUID

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.inputAccessoryView = context.coordinator.makeToolbar()
        textView.text = context.coordinator.generateTextFromModel()

        // 탭 제스처 추가 (기본 터치 이벤트와 함께 동작하도록 설정)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        tapGesture.cancelsTouchesInView = false  // 기본 터치 이벤트를 취소하지 않도록 설정
        textView.addGestureRecognizer(tapGesture)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = context.coordinator.generateTextFromModel()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel, categoryID: categoryID, contentID: contentID)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownEditorView
        var viewModel: MeViewModel
        var categoryID: UUID
        var contentID: UUID

        init(_ parent: MarkdownEditorView, viewModel: MeViewModel, categoryID: UUID, contentID: UUID) {
            self.parent = parent
            self.viewModel = viewModel
            self.categoryID = categoryID
            self.contentID = contentID
        }

        func generateTextFromModel() -> String {
            guard let content = viewModel.meCategoryModelList
                .first(where: { $0.id == categoryID })?
                .contentList.first(where: { $0.id == contentID }) else {
                return ""
            }

            return content.subLines.map { subLine in
                let indent = String(repeating: "\t", count: subLine.indentLevel)
                let prefix = self.prefixForListStyle(subLine.listStyle, isChecked: subLine.isChecked)
                return indent + prefix + subLine.text
            }.joined(separator: "\n")
        }

        func prefixForListStyle(_ style: ListStyle, isChecked: Bool) -> String {
            switch style {
            case .bulleted:
                return "• "
            case .numbered:
                return "1. "
            case .checkbox:
                return isChecked ? "☑ " : "☐ "
            case .none:
                return ""
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            let lines = textView.text.split(separator: "\n", omittingEmptySubsequences: false)
            var updatedSubLines: [SubLineModel] = []

            for line in lines {
                let indentLevel = line.prefix(while: { $0 == "\t" }).count
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let listStyle = determineListStyle(from: trimmedLine)
                let isChecked = trimmedLine.hasPrefix("☑")
                let text = trimmedLine.replacingOccurrences(of: #"^(• |1\. |☐ |☑ )"#, with: "", options: .regularExpression)

                let subLine = SubLineModel(
                    id: UUID(),
                    text: text,
                    indentLevel: indentLevel,
                    listStyle: listStyle,
                    isChecked: isChecked,
                    subLines: []
                )
                updatedSubLines.append(subLine)
            }

            if let categoryIndex = viewModel.meCategoryModelList.firstIndex(where: { $0.id == categoryID }),
               let contentIndex = viewModel.meCategoryModelList[categoryIndex].contentList.firstIndex(where: { $0.id == contentID }) {
                viewModel.meCategoryModelList[categoryIndex].contentList[contentIndex].subLines = updatedSubLines
            }
        }

        func determineListStyle(from line: String) -> ListStyle {
            if line.hasPrefix("•") {
                return .bulleted
            } else if line.hasPrefix("1.") {
                return .numbered
            } else if line.hasPrefix("☐") || line.hasPrefix("☑") {
                return .checkbox
            } else {
                return .none
            }
        }

        func makeToolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()

            let bulletButton = UIBarButtonItem(title: "•", style: .plain, target: self, action: #selector(insertBullet))
            let numberingButton = UIBarButtonItem(title: "1.", style: .plain, target: self, action: #selector(insertNumbering))
            let checkboxButton = UIBarButtonItem(title: "☐", style: .plain, target: self, action: #selector(insertCheckbox))
            let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))

            toolbar.items = [bulletButton, numberingButton, checkboxButton, dismissButton]
            return toolbar
        }

        // 리스트 스타일 삽입 메서드
        @objc func insertBullet() {
            insertListItem(style: .bulleted, prefix: "• ")
        }

        @objc func insertNumbering() {
            insertListItem(style: .numbered, prefix: "1. ")
        }

        @objc func insertCheckbox() {
            insertListItem(style: .checkbox, prefix: "☐ ")
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let textView = gesture.view as? UITextView else { return }
            let location = gesture.location(in: textView)

            // 탭한 위치로 커서를 이동
            if let position = textView.closestPosition(to: location) {
                textView.selectedTextRange = textView.textRange(from: position, to: position)
            }

            // 키보드 활성화
            if !textView.isFirstResponder {
                textView.becomeFirstResponder()
            }

            if let position = textView.closestPosition(to: location),
            let range = textView.tokenizer.rangeEnclosingPosition(position, with: .line, inDirection: UITextDirection(rawValue: 0)),
            let lineText = textView.text(in: range) {

                let checkedPattern = #"^☐ "#  // 체크되지 않은 상태
                let uncheckedPattern = #"^☑ "# // 체크된 상태

                if lineText.hasPrefix("☐ ") || lineText.hasPrefix("☑ ") {
                    toggleCheckbox(in: textView, at: range, with: lineText)
                }
            }
        }

        func toggleCheckbox(in textView: UITextView, at range: UITextRange, with lineText: String) {
            let updatedLine: String
            var newIsChecked: Bool = false

            if lineText.hasPrefix("☐ ") {
                updatedLine = lineText.replacingOccurrences(of: "☐ ", with: "☑ ")
                newIsChecked = true
            } else if lineText.hasPrefix("☑ ") {
                updatedLine = lineText.replacingOccurrences(of: "☑ ", with: "☐ ")
                newIsChecked = false
            } else {
                return
            }

            // 텍스트 뷰에서 체크박스 토글 적용
            textView.replace(range, withText: updatedLine)

            // 모델의 isChecked 값 업데이트
            updateModelCheckboxState(for: lineText, isChecked: newIsChecked)
        }

        func updateModelCheckboxState(for lineText: String, isChecked: Bool) {
            // 현재 contentID에 해당하는 SubLine을 찾고 상태를 업데이트
            if let subLine = viewModel.findSubLine(with: lineText, in: contentID, categoryID: categoryID) {
                var updatedSubLine = subLine
                updatedSubLine.isChecked = isChecked
                viewModel.updateSubLine(in: contentID, categoryID: categoryID, subLine: updatedSubLine)
            }
        }

        func insertListItem(style: ListStyle, prefix: String) {
            guard let textView = findFirstResponder(),
                  let selectedRange = textView.selectedTextRange else { return }
            
            textView.replace(selectedRange, withText: prefix)
        }

        @objc func dismissKeyboard() {
            findFirstResponder()?.resignFirstResponder()
        }

        func findFirstResponder() -> UITextView? {
            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.view.findTextView()
        }
    }
}

extension UIView {
    func findTextView() -> UITextView? {
        if let textView = self as? UITextView {
            return textView
        }
        for subview in subviews {
            if let found = subview.findTextView() {
                return found
            }
        }
        return nil
    }
}

struct PlanView: View {
    @StateObject var viewModel = MeViewModel(meCategoryModelList: mockData_meCategoryModelList, profile: ProfileModel(name: "User", value: "0"))

    var body: some View {
        NavigationView {
            if let firstCategory = viewModel.meCategoryModelList.first,
               let firstContent = firstCategory.contentList.first {
                MarkdownEditorView(viewModel: viewModel, categoryID: firstCategory.id, contentID: firstContent.id)
                    .padding()
            } else {
                Text("No Content Available")
            }
        }
    }
}

// 미리보기
struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
