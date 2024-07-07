//  LoginView.swift
//  ScheduleSmart
//
//  Created by Rushil Mantripragada on 6/18/24.
//

import Foundation
import SwiftUI
import Security

struct LoginView: View {
    @State private var isShowingLogin = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                
                Text("ScheduleSmart")
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

                    Button(action: {
                        // Add your login logic here
                        if let storedPassword = fetchCredentials(username: self.username), storedPassword == self.password {
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            self.isShowingLogin = true
                        } else {
                            // Handle login failure
                            self.alertMessage = "Invalid credentials"
                            self.showAlert = true
                        }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 280, height: 50)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isShowingLogin) {
                ContentView()
            }
        }
    }

    func fetchCredentials(username: String) -> String? {
        let account = username

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess {
            if let data = item as? Data, let password = String(data: data, encoding: .utf8) {
                return password
            }
        } else {
            print("Error fetching credentials: \(status)")
        }

        return nil
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

