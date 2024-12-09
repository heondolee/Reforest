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

        @objc func insertBullet() {
            insertListItem(prefix: "• ")
        }

        @objc func insertNumbering() {
            insertListItem(prefix: "1. ")
        }

        @objc func insertCheckbox() {
            insertListItem(prefix: "☐ ")
        }

        func insertListItem(prefix: String) {
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
                    .navigationTitle("Markdown Editor")
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
