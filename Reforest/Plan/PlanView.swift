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

func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
        let nsText = textView.text as NSString
        let currentLineRange = nsText.lineRange(for: range)
        let currentLine = nsText.substring(with: currentLineRange)

        let indentLevel = currentLine.prefix(while: { $0 == "\t" }).count
        let lines = textView.text.components(separatedBy: "\n")
        let currentIndex = lines.firstIndex(of: currentLine) ?? 0

        var newPrefix: String = ""
        let listStylePattern = #"^\s*(• |(\d+)\.|☐ |☑ )"#
        let regex = try? NSRegularExpression(pattern: listStylePattern)
        
        if let match = regex?.firstMatch(in: currentLine, range: NSRange(currentLine.startIndex..., in: currentLine)) {
            let matchedPrefix = (currentLine as NSString).substring(with: match.range).trimmingCharacters(in: .whitespaces)

            if let numberMatch = match.range(at: 2).location != NSNotFound ? Int((currentLine as NSString).substring(with: match.range(at: 2))) : nil {
                newPrefix = "\(numberMatch + 1). "
            } else if matchedPrefix == "☐" || matchedPrefix == "☑" {
                newPrefix = "☐ "
            } else {
                newPrefix = matchedPrefix + " "
            }
        }

        let newLine = "\n" + String(repeating: "\t", count: indentLevel) + newPrefix

        if let selectedTextRange = textView.selectedTextRange {
            textView.replace(selectedTextRange, withText: newLine)
            if let newPosition = textView.position(from: selectedTextRange.start, offset: newLine.count) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }
        return false
    }
    return true
}


        func determineListStyle(from prefix: String) -> ListStyle {
            let trimmedPrefix = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
            switch trimmedPrefix {
            case "•":
                return .bulleted
            case "1.":
                return .numbered
            case "☐":
                return .checkbox
            default:
                return .none
            }
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

            // 탭한 위치에서 라인 텍스트와 그 범위를 가져옴
            if let position = textView.closestPosition(to: location),
            let range = textView.tokenizer.rangeEnclosingPosition(position, with: .line, inDirection: UITextDirection(rawValue: 0)),
            let lineText = textView.text(in: range) {

                let nsLineText = lineText as NSString
                let checkboxPattern = #"^\s*(☐ |☑ )"#

                if let regex = try? NSRegularExpression(pattern: checkboxPattern),
                let match = regex.firstMatch(in: lineText, options: [], range: NSRange(location: 0, length: nsLineText.length)) {

                    let checkboxRange = match.range(at: 1) // 체크박스 기호 범위

                    // 라인의 시작점으로부터 체크박스의 시작점을 계산
                    let lineStartOffset = textView.offset(from: textView.beginningOfDocument, to: range.start)
                    let checkboxStartOffset = lineStartOffset + checkboxRange.location
                    let checkboxEndOffset = checkboxStartOffset + checkboxRange.length

                    let tapOffset = textView.offset(from: textView.beginningOfDocument, to: position)

                    // 탭 위치가 체크박스 범위 내에 있는지 확인
                    if tapOffset >= checkboxStartOffset && tapOffset <= checkboxEndOffset {
                        toggleCheckbox(in: textView, at: range, with: lineText)
                    }
                }
            }
        }


func toggleCheckbox(in textView: UITextView, at range: UITextRange, with lineText: String) {
    let updatedLine: String
    var newIsChecked: Bool = false

    // 정규식을 사용해 탭이나 공백 이후 체크박스 기호를 찾음
    let pattern = #"^([\t ]*)(☐ |☑ )"#

    if let regex = try? NSRegularExpression(pattern: pattern),
       let match = regex.firstMatch(in: lineText, range: NSRange(lineText.startIndex..., in: lineText)) {
        
        let leadingWhitespace = (lineText as NSString).substring(with: match.range(at: 1))
        print("leadingWhitespace: \(leadingWhitespace)")
        let checkbox = (lineText as NSString).substring(with: match.range(at: 2))
        print("checkbox: \(checkbox)")
        let remainingText = (lineText as NSString).substring(from: match.range.upperBound)
        print("remainingText: \(remainingText)")
        
        if checkbox == "☐ " {
            updatedLine = leadingWhitespace + "☑ " + remainingText
            newIsChecked = true
        } else if checkbox == "☑ " {
            updatedLine = leadingWhitespace + "☐ " + remainingText
            newIsChecked = false
        } else {
            return
        }

        // 텍스트 뷰에서 체크박스 토글 적용
        textView.replace(range, withText: updatedLine)
    }
}

        func insertListItem(style: ListStyle, prefix: String) {
    guard let textView = findFirstResponder(),
          let selectedRange = textView.selectedTextRange,
          let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .line, inDirection: UITextDirection(rawValue: 0)),
          let lineText = textView.text(in: lineRange) else { return }

    let indentLevel = lineText.prefix(while: { $0 == "\t" }).count
    let lines = textView.text.components(separatedBy: "\n")
    let currentIndex = lines.firstIndex(of: lineText) ?? 0

    var number = 1

    // 이전 라인들 중에서 동일한 indentLevel의 마지막 숫자 찾기
    for i in (0..<currentIndex).reversed() {
        let previousLine = lines[i]
        let previousIndentLevel = previousLine.prefix(while: { $0 == "\t" }).count

        if previousIndentLevel == indentLevel {
            let numberPattern = #"^\s*\d+\."#
            if let match = previousLine.range(of: numberPattern, options: .regularExpression) {
                let matchedNumber = previousLine[match].trimmingCharacters(in: .whitespaces).dropLast()
                if let previousNumber = Int(matchedNumber) {
                    number = previousNumber + 1
                }
            }
            break
        }
    }

    let newPrefix: String
    switch style {
    case .numbered:
        newPrefix = "\(number). "
    default:
        newPrefix = prefix
    }

    // 탭이나 공백을 포함한 들여쓰기를 유지하고 리스트 기호만 교체
    let updatedLine = lineText.replacingOccurrences(of: #"^([\t ]*)(• |1\. |☐ |☑ )?"#, with: "$1" + newPrefix, options: .regularExpression)

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
