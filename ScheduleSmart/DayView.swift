//
//  DayView.swift
//  ScheduleSmart
//
//  Created by Saketh Ogirala on 6/25/24.
//

import SwiftUI
import EventKit

struct DayView: View {
    @ObservedObject var calendarManager = CalendarManager()
    
    var body: some View {
        VStack {
            Text("Today")
                .font(.largeTitle)
                .padding()
                .underline()
            
            List(calendarManager.events.filter { Calendar.current.isDateInToday($0.startDate) }) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.startDate, style: .time)
                }
            }
            .onAppear {
                calendarManager.requestAccess()
            }
        }
    }
}

