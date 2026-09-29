import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatManager: ChatManager
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if chatManager.messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("Nenhuma conversa")
                            .font(.headline)
                        
                        Text("Crie uma nova conversa para começar")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            Task {
                                await chatManager.createConversation(
                                    title: "Nova Conversa",
                                    description: nil
                                )
                            }
                        }) {
                            Label("Nova Conversa", systemImage: "plus.circle.fill")
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    // Messages List
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(chatManager.messages) { message in
                                HStack(alignment: .top, spacing: 12) {
                                    if message.role == "user" {
                                        Spacer()
                                        Text(message.content)
                                            .padding(12)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    } else {
                                        Text(message.content)
                                            .padding(12)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(12)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Input Area
                    HStack(spacing: 12) {
                        TextField("Digite sua mensagem...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            if !messageText.isEmpty {
                                Task {
                                    await chatManager.sendMessage(messageText)
                                    messageText = ""
                                }
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("GD IA Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await chatManager.loadConversations()
                }
            }
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(ChatManager())
}