import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isLogin = true
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Logo
                    VStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("GD IA")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Assistente Pessoal Inteligente")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 32)
                    
                    Spacer()
                    
                    // Formulário
                    VStack(spacing: 16) {
                        TextField("Usuário", text: $viewModel.username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Senha", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !isLogin {
                            TextField("Email", text: $viewModel.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Nome Completo", text: $viewModel.fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Botão Principal
                    Button(action: {
                        if isLogin {
                            Task { await viewModel.login() }
                        } else {
                            Task { await viewModel.register() }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isLogin ? "Entrar" : "Registrar")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .disabled(viewModel.isLoading)
                    
                    // Alternar entre login e registro
                    Button(action: { isLogin.toggle(); viewModel.resetForm() }) {
                        HStack {
                            Text(isLogin ? "Não tem conta?" : "Já tem conta?")
                                .foregroundColor(.gray)
                            Text(isLogin ? "Registre-se" : "Faça login")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .font(.caption)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AuthView()
}