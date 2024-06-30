import SwiftUI
import Combine
import EventKit

extension EKEvent: Identifiable {
    public var id: String {
        eventIdentifier
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUserMessage: Bool
}

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var userInput: String = ""
    @State private var selectedTab: Int = 0 // Track selected tab
    @State private var errorMessage: String? = nil // Error message state

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .white]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // title of the app
                Text("Schedule Smart").font(.system(size: 32, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .bold()
                
                Spacer()
                
                // Custom TabView at the bottom
                TabView(selection: $selectedTab) {
                    DayView()
                        .tabItem {
                            CustomTabItem(label: "Day", image: "sun.max.fill", isSelected: $selectedTab, tag: 0)
                        }
                        .tag(0)
                    
                    WeekView()
                        .tabItem {
                            CustomTabItem(label: "Week", image: "calendar", isSelected: $selectedTab, tag: 1)
                        }
                        .tag(1)
                    
                    MonthView()
                        .tabItem {
                            CustomTabItem(label: "Month", image: "calendar.circle.fill", isSelected: $selectedTab, tag: 2)
                        }
                        .tag(2)
                    
                    ChatbotView(messages: $messages, userInput: $userInput, sendRequest: sendRequest)
                        .tabItem {
                            CustomTabItem(label: "Chatbot", image: "message.fill", isSelected: $selectedTab, tag: 3)
                        }
                        .tag(3)
                }
                .accentColor(.black)
            }
        }
    }

    func sendRequest() {
        guard !userInput.isEmpty else { return }
        
        // Append user's message to the conversation
        let userMessage = Message(content: userInput, isUserMessage: true)
        messages.append(userMessage)
        

        let apiKey = "sk-proj-sTMCQVLqzjZRX8x18ggdT3BlbkFJH35tvjy0BurbTVVd0Cd0"
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": userInput]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "No error description"
                }
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Response JSON: \(jsonResponse)") // Debugging print statement
                    
                    if let choices = jsonResponse["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        DispatchQueue.main.async {
                            let botMessage = Message(content: content, isUserMessage: false)
                            self.messages.append(botMessage)
                            self.errorMessage = nil
                            self.userInput = ""
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Invalid response format"
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid JSON response"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error parsing JSON: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
    }
}

struct CustomTabItem: View {
    let label: String
    let image: String
    @Binding var isSelected: Int
    let tag: Int
    
    var body: some View {
        VStack {
            Image(systemName: image)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundColor(isSelected == tag ? .black : .gray)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(isSelected == tag ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(10)
    }
}

struct ChatbotView: View {
    @Binding var messages: [Message]
    @Binding var userInput: String
    var sendRequest: () -> Void
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUserMessage {
                                    Spacer()
                                    Text(message.content)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                } else {
                                    Text(message.content)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                    .onChange(of: messages.count) { newCount, _ in
                        if let lastMessageId = messages.last?.id {
                            scrollView.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
            HStack {
                TextField("Enter your message", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)
                Button(action: {
                    sendRequest()
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.trailing, 8)
            }
            .padding()
        }
    }
}

struct EventListView: View {
    let events: [EKEvent]
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack {
            if let selectedDate = selectedDate {
                
                Text(selectedDate, style: .date)
                    .font(.headline)
                    .padding()
                    .underline()
                
                ScrollView {
                    ForEach(events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }) { event in
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.startDate, style: .time)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            } else {
                Text("No Date Selected")
                    .font(.headline)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
