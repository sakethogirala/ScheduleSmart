//
//  RegistrationView.swift
//  ScheduleSmart
//
//  Created by Rushil Mantripragada on 6/18/24.
//

import Foundation
import SwiftUI

struct RegistrationView: View {
    @State private var isShowingRegistration = false
    var body: some View {
        VStack {
            Button(action: {
                self.isShowingRegistration = true
            }) {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 280, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .fullScreenCover(isPresented: $isShowingRegistration){
                ContentView()
            }
        }
    }
}
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
