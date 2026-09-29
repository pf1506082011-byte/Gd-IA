import SwiftUI

struct MemoryView: View {
    @State private var memories: [Memory] = []
    @State private var searchText = ""
    @State private var showAddMemory = false
    @State private var newKey = ""
    @State private var newValue = ""
    
    var filteredMemories: [Memory] {
        if searchText.isEmpty {
            return memories
        }
        return memories.filter { 
            $0.key.localizedCaseInsensitiveContains(searchText) ||
            $0.value.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                if filteredMemories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "brain")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("Nenhuma memória salva")
                            .font(.headline)
                        
                        Button(action: { showAddMemory = true }) {
                            Label("Adicionar Memória", systemImage: "plus.circle.fill")
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    List(filteredMemories) { memory in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(memory.key)
                                .font(.headline)
                            
                            Text(memory.value)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if let category = memory.category {
                                Text(category)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Memória")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddMemory = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddMemory) {
                AddMemoryView(isPresented: $showAddMemory, key: $newKey, value: $newValue)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar memória...", text: $text)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AddMemoryView: View {
    @Binding var isPresented: Bool
    @Binding var key: String
    @Binding var value: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Chave", text: $key)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextEditor(text: $value)
                    .frame(height: 150)
                    .border(Color.gray.opacity(0.3))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Adicionar Memória")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        // Save memory
                        isPresented = false
                    }
                    .disabled(key.isEmpty || value.isEmpty)
                }
            }
        }
    }
}

#Preview {
    MemoryView()
}
