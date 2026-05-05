import SwiftUI

struct RegisterView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var vm = AuthViewModel()

    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.isEmpty && email.contains("@") &&
        password.count >= 6
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)

                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Start tracking your goals today")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    VStack(spacing: 20) {
                        AuthTextField(icon: "person.fill", placeholder: "Full Name", text: $name)
                        AuthTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
                        AuthTextField(icon: "lock.fill", placeholder: "Password (min 6 chars)", text: $password, isSecure: true)

                        if let err = vm.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(err).font(.caption)
                            }
                            .foregroundColor(Color(hex: "F87171"))
                        }

                        Button {
                            Task { await vm.register(name: name, email: email, password: password, authManager: authManager) }
                        } label: {
                            ZStack {
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create Account")
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
                        .disabled(vm.isLoading || !isFormValid)
                        .opacity(!isFormValid ? 0.5 : 1)

                        Button { dismiss() } label: {
                            HStack(spacing: 4) {
                                Text("Already have an account?").foregroundColor(.white.opacity(0.6))
                                Text("Sign In").foregroundColor(Color(hex: "A78BFA")).bold()
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
    }
}
