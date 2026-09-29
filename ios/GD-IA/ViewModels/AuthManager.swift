import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User? = nil
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    
    func login(username: String, password: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await apiService.login(username: username, password: password)
            
            await MainActor.run {
                self.accessToken = response.access_token
                self.refreshToken = response.refresh_token
                self.isAuthenticated = true
                self.isLoading = false
                
                // Salvar tokens no Keychain
                KeychainManager.save(token: response.access_token, key: "accessToken")
                KeychainManager.save(token: response.refresh_token, key: "refreshToken")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erro ao fazer login: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func register(username: String, email: String, password: String, fullName: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            _ = try await apiService.register(username: username, email: email, password: password, fullName: fullName)
            
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Registro bem-sucedido! Faça login agora."
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erro ao registrar: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        accessToken = nil
        refreshToken = nil
        KeychainManager.delete(key: "accessToken")
        KeychainManager.delete(key: "refreshToken")
    }
    
    func restoreSession() {
        if let token = KeychainManager.load(key: "accessToken") {
            self.accessToken = token
            self.isAuthenticated = true
        }
    }
}

// Keychain Manager para armazenar tokens com segurança
class KeychainManager {
    static func save(token: String, key: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
