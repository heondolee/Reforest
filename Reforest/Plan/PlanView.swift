import SwiftUI

struct MarkdownLine: Identifiable {
    let id = UUID()
    var text: String
    var indentation: Int = 0 // 들여쓰기 수준
}

class MarkdownViewModel: ObservableObject {
    @Published var lines: [MarkdownLine] = [MarkdownLine(text: "")]
    
    func updateLine(at index: Int, with newText: String) {
        if newText == "" {
            lines[index].text = ""
            return
        }
        
        var updatedText = newText
        
        // 불렛 목록 변환
        if updatedText == "- " || updatedText == "* " || updatedText == "+ " {
            updatedText = "• "
        }
        // 숫자 목록 변환
        else if let match = updatedText.range(of: #"^\d+\.\s"#, options: .regularExpression) {
            updatedText = updatedText.replacingCharacters(in: match, with: "1. ")
        }
        // 알파벳 목록 변환
        else if let match = updatedText.range(of: #"^[a-zA-Z]\.\s"#, options: .regularExpression) {
            updatedText = updatedText.replacingCharacters(in: match, with: "a. ")
        }
        
        lines[index].text = updatedText
    }
    
    func addNewLine(at index: Int) {
        lines.insert(MarkdownLine(text: ""), at: index + 1)
    }
    
    func adjustIndentation(for index: Int, increase: Bool) {
        if increase {
            lines[index].indentation += 1
        } else if lines[index].indentation > 0 {
            lines[index].indentation -= 1
        }
    }
}

struct PlanView: View {
    @StateObject private var viewModel = MarkdownViewModel()
    @FocusState private var focusedIndex: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.lines.indices, id: \.self) { index in
                        TextField("Enter text", text: Binding(
                            get: { viewModel.lines[index].text },
                            set: { newText in viewModel.updateLine(at: index, with: newText) }
                        ))
                        .focused($focusedIndex, equals: index)
                        .padding(.leading, CGFloat(viewModel.lines[index].indentation) * 20)
                        .onSubmit {
                            viewModel.addNewLine(at: index)
                        }
                    }
                }
            }
            
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: { applyBullet() }) {
                        Image(systemName: "list.bullet")
                    }
                    Button(action: { applyNumberedList() }) {
                        Image(systemName: "list.number")
                    }
                    Button(action: { increaseIndentation() }) {
                        Image(systemName: "arrow.right.to.line")
                    }
                    Button(action: { decreaseIndentation() }) {
                        Image(systemName: "arrow.left.to.line")
                    }
                }
            }
            .navigationTitle("Markdown Editor")
        }
    }
    
    private func applyBullet() {
        if let index = focusedIndex {
            viewModel.updateLine(at: index, with: "- ")
        }
    }
    
    private func applyNumberedList() {
        if let index = focusedIndex {
            viewModel.updateLine(at: index, with: "1. ")
        }
    }
    
    private func increaseIndentation() {
        if let index = focusedIndex {
            viewModel.adjustIndentation(for: index, increase: true)
        }
    }
    
    private func decreaseIndentation() {
        if let index = focusedIndex {
            viewModel.adjustIndentation(for: index, increase: false)
        }
    }
}

