//
//  CusTextEditorView.swift
//  Reforest
//
//  Created by Heondo Lee on 12/10/24.
//

import SwiftUI
import UIKit

struct MarkdownEditorView: UIViewRepresentable {
    @Binding var text: String
    @Binding var overlays: [OverlayItem]
    @ObservedObject var viewModel: MeViewModel
    var categoryID: UUID
    var contentID: UUID

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        context.coordinator.textView = textView // Coordinator에 UITextView 저장
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.inputAccessoryView = context.coordinator.makeToolbar()

        // 텍스트 뷰에 패딩 추가
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
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
        weak var textView: UITextView? // UITextView를 저장할 약한 참조

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
            updateOverlays(for: textView)
        }

func updateOverlays(for textView: UITextView) {
    var newOverlays: [OverlayItem] = []
    let lines = textView.text.components(separatedBy: "\n")

    // 각 라인의 높이와 들여쓰기 간격 설정
    let lineHeight: CGFloat = 19.5
    let indentWidth: CGFloat = 27.0

    for (index, line) in lines.enumerated() {
        let indentLevel = line.prefix(while: { $0 == "\t" }).count
        let positionY = CGFloat(index) * lineHeight + 43.0
        let positionX = CGFloat(indentLevel) * indentWidth + 25.0

        // 자식 노드가 있는지 확인 (다음 줄의 들여쓰기 수준이 현재보다 깊은 경우)
        let hasChild = (index + 1 < lines.count) && lines[index + 1].prefix(while: { $0 == "\t" }).count > indentLevel

        if hasChild {
            // 화살표 추가 (텍스트와 정렬되도록 위치 조정)
            newOverlays.append(OverlayItem(position: CGPoint(x: positionX, y: positionY - 5.0), isArrow: true))

            // 자식 노드의 개수 확인
            let childCount = lines[(index + 1)...].prefix { $0.prefix(while: { $0 == "\t" }).count > indentLevel }.count

            // 세로 줄의 길이를 자식 노드의 개수에 맞게 설정
            let verticalLineHeight = CGFloat(childCount) * lineHeight

            // 세로 줄 추가 (화살표의 위치에서 시작하도록 설정)
            newOverlays.append(OverlayItem(position: CGPoint(x: positionX, y: positionY + verticalLineHeight / 2 + 2), isArrow: false, height: verticalLineHeight))
        }
    }

    parent.overlays = newOverlays
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
            // findFirstResponder 확인
            guard let textView = findFirstResponder() else {
                print("⚠️ 텍스트 뷰를 찾을 수 없습니다.")
                return
            }
            print("✅ 텍스트 뷰를 성공적으로 찾았습니다.")

            // 선택된 범위와 라인 범위 확인
            guard let selectedRange = textView.selectedTextRange,
                let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .line, inDirection: UITextDirection(rawValue: 0)),
                let lineText = textView.text(in: lineRange) else {
                print("⚠️ 선택된 범위나 라인 텍스트를 가져오지 못했습니다.")
                return
            }

            print("📝 선택된 라인 텍스트: '\(lineText)'")

            // 들여쓰기 수준 확인
            let indentLevel = lineText.prefix(while: { $0 == "\t" }).count
            print("🔹 들여쓰기 수준: \(indentLevel)")

            // 현재 라인의 인덱스 확인
            let lines = textView.text.components(separatedBy: "\n")
            let currentIndex = lines.firstIndex(of: lineText) ?? 0
            print("🔹 현재 라인 인덱스: \(currentIndex)")

            var number = 1

            // 이전 라인에서 동일한 들여쓰기 수준의 마지막 숫자 찾기
            for i in (0..<currentIndex).reversed() {
                let previousLine = lines[i]
                let previousIndentLevel = previousLine.prefix(while: { $0 == "\t" }).count

                print("🔍 이전 라인: '\(previousLine)', 들여쓰기 수준: \(previousIndentLevel)")

                if previousIndentLevel == indentLevel {
                    let numberPattern = #"^\s*\d+\."#
                    if let match = previousLine.range(of: numberPattern, options: .regularExpression) {
                        let matchedNumber = previousLine[match].trimmingCharacters(in: .whitespaces).dropLast()
                        if let previousNumber = Int(matchedNumber) {
                            number = previousNumber + 1
                            print("🔢 이전 번호: \(previousNumber), 다음 번호: \(number)")
                        }
                    }
                    break
                } else if previousIndentLevel < indentLevel {
                    number = 1
                    print("🔄 부모가 다르므로 번호를 1로 초기화합니다.")
                    break
                }
            }

            // 새 프리픽스 설정
            let newPrefix: String
            switch style {
            case .numbered:
                newPrefix = "\(number). "
            default:
                newPrefix = prefix
            }

            print("🆕 새 프리픽스: '\(newPrefix)'")

            // 라인 업데이트
            let updatedLine = lineText.replacingOccurrences(of: #"^([\t ]*)(• |\d+\.|☐ |☑ )?"#, with: "$1" + newPrefix, options: .regularExpression)
            print("✅ 업데이트된 라인: '\(updatedLine)'")

            textView.replace(lineRange, withText: updatedLine)
            print("✅ 라인 업데이트가 완료되었습니다.")
        }

        @objc func indentText() {
            guard let textView = findFirstResponder(),
                let selectedRange = textView.selectedTextRange,
                let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .line, inDirection: UITextDirection(rawValue: 0)),
                let lineText = textView.text(in: lineRange) else { return }

            let indentedLine = "\t" + lineText
            textView.replace(lineRange, withText: indentedLine)

            // 들여쓰기를 적용한 후, 리스트 번호를 업데이트
            updateListNumbers(in: textView)
        }

        @objc func outdentText() {
            guard let textView = findFirstResponder(),
                let selectedRange = textView.selectedTextRange,
                let lineRange = textView.tokenizer.rangeEnclosingPosition(selectedRange.start, with: .line, inDirection: UITextDirection(rawValue: 0)),
                let lineText = textView.text(in: lineRange) else { return }

            let updatedLine = lineText.replacingOccurrences(of: #"^(?:\t| {4})"#, with: "", options: .regularExpression)
            textView.replace(lineRange, withText: updatedLine)

            // 내어쓰기를 적용한 후, 리스트 번호를 업데이트
            updateListNumbers(in: textView)
        }

        func updateListNumbers(in textView: UITextView) {
            let lines = textView.text.components(separatedBy: "\n")
            var updatedLines = [String]()
            var numberStack: [Int] = []
            var indentStack: [Int] = []

            for line in lines {
                let indentLevel = line.prefix(while: { $0 == "\t" }).count

                // 현재 indentLevel에 맞는 번호 설정
                while indentStack.count > indentLevel {
                    indentStack.removeLast()
                    numberStack.removeLast()
                }

                if let match = line.range(of: #"^(\t*)(\d+\.)"#, options: .regularExpression) {
                    if indentStack.last == indentLevel {
                        // 동일한 레벨이면 번호 증가
                        numberStack[numberStack.count - 1] += 1
                    } else {
                        // 새로운 레벨이면 1부터 시작
                        numberStack.append(1)
                        indentStack.append(indentLevel)
                    }

                    let newNumber = "\(numberStack.last!)."

                    if let matchRange = line.range(of: #"^(\t*)(\d+\.)"#, options: .regularExpression) {
                        let newNumber = "\(numberStack.last!)."
                        let indent = String(line[matchRange].prefix { $0 == "\t" })  // 들여쓰기 부분 추출
                        let updatedLine = line.replacingCharacters(in: matchRange, with: "\(indent)\(newNumber)")
                        updatedLines.append(updatedLine)
                    }
                    
                } else {
                    // 리스트가 아닌 경우 그대로 추가
                    updatedLines.append(line)
                }
            }

            textView.text = updatedLines.joined(separator: "\n")
        }


        @objc func dismissKeyboard() {
            findFirstResponder()?.resignFirstResponder()
        }

        func findFirstResponder() -> UITextView? {
            return self.textView
        }
    }
}

extension UIView {
    func findTextView() -> UITextView? {
        if let textView = self as? UITextView {
            print("✅ UITextView를 발견했습니다: \(textView)")
            return textView
        }
        for subview in subviews {
            if let found = subview.findTextView() {
                return found
            }
        }
        print("⚠️ \(self)에서 UITextView를 찾지 못했습니다.")
        return nil
    }
}


// 오버레이 아이템 구조체
struct OverlayItem: Identifiable {
    let id = UUID()
    let position: CGPoint
    let isArrow: Bool
    var height: CGFloat = 20.0  // 기본 높이를 20.0으로 설정
}

// SwiftUI View
import SwiftUI

struct CusTextEditorView: View {
    @ObservedObject var viewModel: MeViewModel
    @Binding var text: String
    @State private var overlays: [OverlayItem] = []

    let categoryID: UUID
    let contentID: UUID
    let sublineID: UUID

    init(viewModel: MeViewModel, text: Binding<String>, categoryID: UUID, contentID: UUID, sublineID: UUID) {
        self.viewModel = viewModel
        self._text = text
        self.categoryID = categoryID
        self.contentID = contentID
        self.sublineID = sublineID
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 텍스트 뷰
            MarkdownEditorView(
                text: $text,
                overlays: $overlays,
                viewModel: viewModel,
                categoryID: categoryID,
                contentID: contentID
            )
            .padding()

            // 오버레이로 화살표와 줄 표시
            ForEach(overlays) { item in
                if item.isArrow {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .position(item.position)
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: item.height)
                        .position(item.position)
                }
            }
        }
        .navigationTitle("Markdown Editor")
    }
}

