//  RegistrationView.swift
//  ScheduleSmart
//
//  Created by Rushil Mantripragada on 6/18/24.
//

import Foundation
import SwiftUI
import Security

struct RegistrationView: View {
    @State private var isShowingRegistration = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.7), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                VStack(spacing: 20) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)

                    Button(action: {
                        // Add your validation logic here
                        if self.password == self.confirmPassword {
                            saveCredentials(username: self.username, password: self.password)
                            self.isShowingRegistration = true
                        } else {
                            // Handle password mismatch error
                            self.alertMessage = "Passwords do not match"
                            self.showAlert = true
                        }
                    }) {
                        Text("Register")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 280, height: 50)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Registration Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isShowingRegistration) {
                ContentView()
            }
        }
    }

    func saveCredentials(username: String, password: String) {
        let account = username
        let passwordData = password.data(using: String.Encoding.utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData
        ]

        // Add the new keychain item.
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("Credentials saved successfully.")
        } else if status == errSecDuplicateItem {
            // Update existing item
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: passwordData
            ]

            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account
            ]

            let status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)

            if status == errSecSuccess {
                print("Credentials updated successfully.")
            } else {
                print("Error updating credentials: \(status)")
            }
        } else {
            print("Error saving credentials: \(status)")
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

