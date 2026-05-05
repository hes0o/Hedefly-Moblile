import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var vm = AuthViewModel()

    @State private var email    = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)

                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(hex: "A78BFA"), Color(hex: "818CF8")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))

                        Text("Hedefly")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Your goals, your pace.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Card
                    VStack(spacing: 20) {
                        AuthTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
                        AuthTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)

                        if let err = vm.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(err)
                                    .font(.caption)
                            }
                            .foregroundColor(Color(hex: "F87171"))
                            .padding(.horizontal, 4)
                        }

                        Button {
                            Task { await vm.login(email: email, password: password, authManager: authManager) }
                        } label: {
                            ZStack {
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(vm.isLoading || email.isEmpty || password.isEmpty)
                        .opacity((email.isEmpty || password.isEmpty) ? 0.5 : 1)

                        Button { showRegister = true } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?").foregroundColor(.white.opacity(0.6))
                                Text("Sign Up").foregroundColor(Color(hex: "A78BFA")).bold()
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 20)
                }
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}
