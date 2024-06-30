import SwiftUI
import EventKit

struct DayView: View {
    @ObservedObject var calendarManager = CalendarManager()
    @State private var selectedSegment = 0
    @State private var selectedDate: Date? = Date()

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
                                }
                            )
                        }
                    }
                }
            } else {
                EventListView(events: calendarManager.events.filter {
                    if let selectedDate = selectedDate {
                        return Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate)
                    }
                    return false
                }, selectedDate: $selectedDate)
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
