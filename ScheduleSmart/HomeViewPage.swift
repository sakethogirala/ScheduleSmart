import SwiftUI

struct HomePageView: View {
    @State private var isShowingLogin = false
    @State private var isShowingRegistration = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Welcome to ScheduleSmart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text("Your personal AI scheduling assistant")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()

                Spacer()

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
                .sheet(isPresented: $isShowingLogin) {
                    LoginView()
                }

                Button(action: {
                    self.isShowingRegistration = true
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 280, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $isShowingRegistration) {
                    RegistrationView()
                }

                Spacer()
            }
        }
    }
}
#Preview {
    HomePageView()
}
