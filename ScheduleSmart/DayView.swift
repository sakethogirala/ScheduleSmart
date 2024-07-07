import SwiftUI
import EventKit

struct DayView: View {
    @ObservedObject var calendarManager = CalendarManager()
    @State private var selectedSegment = 0
    @State private var selectedDate: Date? = Date()
    @State private var showingEventCreation = false

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: selectedDate ?? Date())
    }

    private let hours = Array(0...23).map { String(format: "%02d:00", $0) }

    var body: some View {
        VStack(alignment: .leading) {
            Text(currentDate)
                .font(.largeTitle)
                .padding()
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading) // Align to the leading edge
            
            Picker("", selection: $selectedSegment) {
                Text("Calendar").tag(0)
                Text("Events").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedSegment == 0 {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            HStack(alignment: .top) {
                                Text(hour)
                                    .font(.system(size: 14))
                                    .frame(width: 50, alignment: .leading)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                                    .padding(.vertical, 10)
                                Spacer()
                            }
                            .frame(height: 60)
                            .background(
                                ZStack(alignment: .topLeading) {
                                    ForEach(calendarManager.events) { event in
                                        if let selectedDate = selectedDate,
                                           Calendar.current.isDate(event.startDate, inSameDayAs: selectedDate),
                                           Calendar.current.component(.hour, from: event.startDate) == Int(hour.prefix(2)) {
                                            EventView(event: event)
                                        }
                                    }
                                    if hour == String(format: "%02d:00", Calendar.current.component(.hour, from: Date())) {
                                        LiveLine()
                                    }
                                }
                            )
                        }
                    }
                }
            } else {
                List(calendarManager.events.filter { Calendar.current.isDateInToday($0.startDate) }) { event in
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.startDate, style: .date)
                        Text(event.startDate, style: .time)
                    }
                }
                
                .onAppear {
                    calendarManager.requestAccess()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingEventCreation = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                        .sheet(isPresented: $showingEventCreation) {
                            EventCreationView(eventStore: calendarManager.eventStore)
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                .onAppear {
                    calendarManager.requestAccess()
                }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            calendarManager.requestAccess()
        }
    }
}

struct EventView: View {
    var event: EKEvent

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.headline)
                .foregroundColor(.white)
            Text(event.startDate, style: .time)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(5)
        .background(Color.blue)
        .cornerRadius(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 55)
        .padding(.top, CGFloat(Calendar.current.component(.minute, from: event.startDate)) * 60 / 60) // Position by minutes
    }
}

struct LiveLine: View {
    var body: some View {
        TimelineView(.everyMinute) { context in
            VStack(alignment: .leading) {
                HStack {
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(height: 2)
                    Text(DateFormatter.localizedString(from: context.date, dateStyle: .none, timeStyle: .short))
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .offset(y: CGFloat(Calendar.current.component(.minute, from: context.date)))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 55)
        }
    }
}
