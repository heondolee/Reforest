import SwiftUI
import UIKit

struct MarkdownEditorView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.inputAccessoryView = context.coordinator.makeToolbar()
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownEditorView

        init(_ parent: MarkdownEditorView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        // 툴바 생성 메서드
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

        // 툴바 버튼 액션 메서드들
        @objc func insertBullet() {
            insertText("• ")
        }

        @objc func insertNumbering() {
            insertText("1. ")
        }

        @objc func insertCheckbox() {
            insertText("☐ ")
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

            // 줄 맨 앞의 탭 문자(\t) 또는 스페이스 4칸을 제거
            let updatedLine = lineText.replacingOccurrences(of: #"^(?:\t| {4})"#, with: "", options: .regularExpression)
            textView.replace(lineRange, withText: updatedLine)
        }

        @objc func dismissKeyboard() {
            findFirstResponder()?.resignFirstResponder()
        }

        // 텍스트뷰에 텍스트 삽입
        func insertText(_ text: String) {
            if let textView = findFirstResponder(), let range = textView.selectedTextRange {
                textView.replace(range, withText: text)
            }
        }

        // 현재 활성화된 텍스트뷰 찾기
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
    @State private var text = ""

    var body: some View {
        VStack {
            MarkdownEditorView(text: $text)
                .padding()
        }
        .navigationTitle("Markdown Editor")
    }
}
