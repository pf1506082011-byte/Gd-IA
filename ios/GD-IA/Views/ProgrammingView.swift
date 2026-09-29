import SwiftUI

struct ProgrammingView: View {
    @State private var code = ""
    @State private var selectedLanguage = "python"
    @State private var output = ""
    
    let languages = ["python", "javascript", "bash", "swift"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Language Picker
                Picker("Linguagem", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) { lang in
                        Text(lang).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Code Editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Código")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $code)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 150)
                        .border(Color.gray.opacity(0.3))
                }
                .padding()
                
                // Execute Button
                Button(action: {
                    // Execute code
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Executar")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .disabled(code.isEmpty)
                
                // Output
                if !output.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Saída")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        ScrollView {
                            Text(output)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                        }
                        .frame(height: 150)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Programação")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProgrammingView()
}