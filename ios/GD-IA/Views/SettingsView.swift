import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var voiceEnabled = true
    @State private var notificationsEnabled = true
    @State private var darkMode = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Voz") {
                    Toggle("Voz Habilitada", isOn: $voiceEnabled)
                    
                    Picker("Idioma", selection: .constant("pt-BR")) {
                        Text("Português (Brasil)").tag("pt-BR")
                        Text("Inglês (EUA)").tag("en-US")
                        Text("Espanhol").tag("es-ES")
                    }
                    
                    Stepper("Velocidade: 1.0x", value: .constant(1.0), in: 0.5...2.0, step: 0.1)
                }
                
                Section("Notificações") {
                    Toggle("Notificações", isOn: $notificationsEnabled)
                }
                
                Section("Aparência") {
                    Toggle("Modo Escuro", isOn: $darkMode)
                }
                
                Section("Sobre") {
                    HStack {
                        Text("Versão")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Desenvolvedor")
                        Spacer()
                        Text("GD Team")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sair")
                        }
                    }
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}