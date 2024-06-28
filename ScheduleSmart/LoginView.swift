//
//  LoginView.swift
//  ScheduleSmart
//
//  Created by Rushil Mantripragada on 6/18/24.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State private var isShowingLogin = false
    
    var body: some View {
        VStack {
            Button(action: {
                self.isShowingLogin = true
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 280, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .fullScreenCover(isPresented: $isShowingLogin) {
                ContentView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
