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
    @ObservedObject var calendarManager = CalendarManager()
    
    var body: some View {
        VStack {
            Text("This Week")
                .font(.largeTitle)
                .padding()
                .underline()
            
            List(calendarManager.events.filter { Calendar.current.isDate($0.startDate, equalTo: Date(), toGranularity: .weekOfYear) }) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.startDate, style: .date)
                    Text(event.startDate, style: .time)
                }
            }
        }
        .onAppear {
            calendarManager.requestAccess()
        }
    }
}


