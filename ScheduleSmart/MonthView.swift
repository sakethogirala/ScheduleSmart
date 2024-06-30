//
//  MonthView.swift
//  ScheduleSmart
//
//  Created by Saketh Ogirala on 6/25/24.
//

import Foundation
import SwiftUI
import EventKit

struct MonthView: View {
    @ObservedObject var calendarManager = CalendarManager()
    @State private var selectedSegment = 0
    @State private var selectedDate: Date? = Date()
    
    private var currentDate: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
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
                CalendarView(selectedDate: $selectedDate)
                    .frame(maxHeight: 400) // Adjust height as needed
                if let selectedDate = selectedDate {
                    HourEventsView(events: calendarManager.events, selectedDate: selectedDate)
                        .onAppear {
                            calendarManager.requestAccess()
                        }
                }
            } else {
                EventListView(events: calendarManager.events, selectedDate: $selectedDate)
                    .onAppear {
                        calendarManager.requestAccess()
                    }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
