//
//  AuthenticationView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isLoginMode = true
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Mode", selection: $isLoginMode) {
                        Text("Sign In").tag(true)
                        Text("Register").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !isLoginMode {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    SecureField("Password", text: $password)
                    
                    if !isLoginMode {
                        SecureField("Confirm Password", text: $confirmPassword)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await handleAuthentication()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            Text(isLoginMode ? "Sign In" : "Register")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .navigationTitle(isLoginMode ? "Sign In" : "Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(isLoginMode ? "Successfully signed in!" : "Account created successfully!")
            }
        }
    }
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !username.isEmpty && !password.isEmpty
        } else {
            return !username.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
        }
    }
    
    private func handleAuthentication() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if isLoginMode {
                _ = try await BackendService.shared.authenticate(username: username, password: password)
            } else {
                _ = try await BackendService.shared.registerUser(username: username, email: email, password: password)
            }
            
            showSuccess = true
            // Auto-dismiss after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    AuthenticationView()
}

