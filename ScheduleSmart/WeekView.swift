//
//  WeekView.swift
//  ScheduleSmart
//
//  Created by Saketh Ogirala on 6/25/24.
//

import Foundation
import SwiftUI
import EventKit

struct WeekView: View {
    @State private var selectedSegment = 0
    @ObservedObject var calendarManager = CalendarManager()
    private var currentDate: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
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
                EventListView(events: calendarManager.events.filter { Calendar.current.isDateInWeekend($0.startDate) })
                    .onAppear {
                        calendarManager.requestAccess()
                    }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}


