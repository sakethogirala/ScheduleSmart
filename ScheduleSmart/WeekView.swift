//
//  WeekView.swift
//  ScheduleSmart
//
//  Created by Saketh Ogirala on 6/25/24.
//

import Foundation
import SwiftUI
import EventKit
import FSCalendar


struct WeekView: View {
    @State private var selectedSegment = 0
    @ObservedObject var calendarManager = CalendarManager()
    @State private var selectedDate: Date? = Date()
    @State private var showingEventCreation = false // Add this line
    
    private var currentDate: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private let hours = Array(0...23).map { String(format: "%02d:00", $0) }
    
    var body: some View {
        VStack {
            Text(currentDate)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding()
                .bold()
                .underline()
            
            Picker("", selection: $selectedSegment) {
                Text("Calendar").tag(0)
                Text("Events").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedSegment == 0 {
                WeekViewContent(selectedDate: $selectedDate)
//                    .frame(maxHeight: 200) // Adjust height as needed
                if let selectedDate = selectedDate {
                    HourEventsView(events: calendarManager.events, selectedDate: selectedDate)
                        .onAppear {
                            calendarManager.requestAccess()
                        }
                }
            } else {
                List(calendarManager.events.filter { Calendar.current.isDate($0.startDate, equalTo: Date(), toGranularity: .weekOfYear) }) { event in
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
    }
}



struct WeekViewContent: UIViewRepresentable {
    @Binding var selectedDate: Date?

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.scope = .week
        calendar.delegate = context.coordinator
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        if let selectedDate = selectedDate {
            uiView.select(selectedDate)
            uiView.setCurrentPage(selectedDate, animated: true)
        } else {
            uiView.deselect(Date())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate {
        var parent: WeekViewContent

        init(_ parent: WeekViewContent) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
    }
}
