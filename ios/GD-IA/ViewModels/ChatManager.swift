import Foundation
import Combine

class ChatManager: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation? = nil
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    
    func createConversation(title: String, description: String? = nil) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let conversation = try await apiService.createConversation(title: title, description: description)
            
            await MainActor.run {
                self.conversations.append(conversation)
                self.currentConversation = conversation
                self.messages = []
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erro ao criar conversa: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func loadConversations() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let conversations = try await apiService.listConversations()
            
            await MainActor.run {
                self.conversations = conversations
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erro ao carregar conversas: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func loadMessages(conversationId: String) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let messages = try await apiService.getMessages(conversationId: conversationId)
            
            await MainActor.run {
                self.messages = messages
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erro ao carregar mensagens: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func sendMessage(_ content: String, type: String = "text") async {
        guard let conversationId = currentConversation?.id else { return }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let message = try await apiService.sendMessage(
                conversationId: conversationId,
                content: content,
                type: type
            )
            
            await MainActor.run {
                self.messages.append(message)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erro ao enviar mensagem: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func selectConversation(_ conversation: Conversation) async {
        await MainActor.run {
            self.currentConversation = conversation
        }
        
        await loadMessages(conversationId: conversation.id)
    }
}

// Models para Chat
struct Conversation: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
}

struct Message: Codable, Identifiable {
    let id: String
    let role: String // "user" ou "assistant"
    let content: String
    let messageType: String
    let createdAt: String
}
