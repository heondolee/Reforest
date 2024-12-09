import SwiftUI
import UIKit

struct MarkdownEditorView: UIViewRepresentable {
    @Binding var text: String
    @ObservedObject var viewModel: MeViewModel
    var categoryID: UUID
    var contentID: UUID

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.inputAccessoryView = context.coordinator.makeToolbar()
        
        // 탭 제스처 추가 (기본 터치 이벤트와 함께 동작하도록 설정)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        tapGesture.cancelsTouchesInView = false  // 기본 터치 이벤트를 취소하지 않도록 설정
        textView.addGestureRecognizer(tapGesture)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
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

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func makeToolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()

            let bulletButton = UIBarButtonItem(title: "•", style: .plain, target: self, action: #selector(insertBullet))
            let numberingButton = UIBarButtonItem(title: "1.", style: .plain, target: self, action: #selector(insertNumbering))
            let checkboxButton = UIBarButtonItem(title: "☐", style: .plain, target: self, action: #selector(insertCheckbox))
            let indentButton = UIBarButtonItem(title: "→", style: .plain, target: self, action: #selector(indentText))
            let outdentButton = UIBarButtonItem(title: "←", style: .plain, target: self, action: #selector(outdentText))
            let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))

            toolbar.items = [bulletButton, numberingButton, checkboxButton, indentButton, outdentButton, dismissButton]
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
            let newSubLine = SubLineModel(
                id: UUID(),
                text: prefix + "New item",
                indentLevel: 0,
                listStyle: style,
                isChecked: false,
                subLines: []
            )

            viewModel.addSubLine(to: contentID, in: categoryID, subLine: newSubLine)
            // 현재 줄의 맨 앞 기호를 새로운 기호로 교체
            guard let textView = findFirstResponder(),
                let selectedRange = textView.selectedTextRange,
                let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .line, inDirection: UITextDirection(rawValue: 0)),
                let lineText = textView.text(in: lineRange) else { return }

            // 기존 기호를 제거하고 새로운 기호로 교체
            let updatedLine = lineText.replacingOccurrences(of: #"^(• |1\. |☐ )?"#, with: prefix, options: .regularExpression)
            textView.replace(lineRange, withText: updatedLine)
        }

        @objc func indentText() {
            guard let textView = findFirstResponder(),
                  let selectedRange = textView.selectedTextRange,
                  let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .line, inDirection: UITextDirection(rawValue: 0)),
                  let lineText = textView.text(in: lineRange) else { return }

            let indentedLine = "\t" + lineText
            textView.replace(lineRange, withText: indentedLine)
        }

        @objc func outdentText() {
            guard let textView = findFirstResponder(),
                  let selectedRange = textView.selectedTextRange,
                  let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .line, inDirection: UITextDirection(rawValue: 0)),
                  let lineText = textView.text(in: lineRange) else { return }

            let updatedLine = lineText.replacingOccurrences(of: #"^(?:\t| {4})"#, with: "", options: .regularExpression)
            textView.replace(lineRange, withText: updatedLine)
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
    @StateObject var viewModel = MeViewModel(meCategoryModelList: [], profile: ProfileModel(name: "User", value: "0"))
    @State private var text = ""

    var body: some View {
        VStack {
            MarkdownEditorView(text: $text, viewModel: viewModel, categoryID: UUID(), contentID: UUID())
                .padding()
        }
        .navigationTitle("Markdown Editor")
    }
}
