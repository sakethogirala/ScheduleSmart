//
//  DayView.swift
//  ScheduleSmart
//
//  Created by Saketh Ogirala on 6/25/24.
//

import SwiftUI
import EventKit

struct DayView: View {
    @State private var selectedSegment = 0
    @ObservedObject var calendarManager = CalendarManager()
    private var currentDate: String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
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
                CalendarView()
            } else {
                EventListView(events: calendarManager.events.filter { Calendar.current.isDateInToday($0.startDate) })
                    .onAppear {
                        calendarManager.requestAccess()
                    }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

