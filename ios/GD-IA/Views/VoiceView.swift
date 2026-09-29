import SwiftUI

struct VoiceView: View {
    @EnvironmentObject var voiceManager: VoiceManager
    @State private var textToSpeak = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Gravação de Áudio
                VStack(spacing: 16) {
                    Text("Gravação de Áudio")
                        .font(.headline)
                    
                    Button(action: {
                        if voiceManager.isRecording {
                            voiceManager.stopRecording()
                            Task {
                                await voiceManager.speechToText()
                            }
                        } else {
                            voiceManager.startRecording()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: voiceManager.isRecording ? "stop.circle.fill" : "record.circle.fill")
                                .font(.system(size: 24))
                            
                            Text(voiceManager.isRecording ? "Parar Gravação" : "Iniciar Gravação")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(voiceManager.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if !voiceManager.recordedText.isEmpty {
                        Text(voiceManager.recordedText)
                            .padding(12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                // Síntese de Voz
                VStack(spacing: 16) {
                    Text("Sintetizar Áudio")
                        .font(.headline)
                    
                    TextEditor(text: $textToSpeak)
                        .frame(height: 100)
                        .border(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                    
                    Button(action: {
                        Task {
                            await voiceManager.textToSpeech(textToSpeak)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Falar")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(textToSpeak.isEmpty || voiceManager.isPlaying)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                Spacer()
                
                if let error = voiceManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Voz")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    VoiceView()
        .environmentObject(VoiceManager())
}