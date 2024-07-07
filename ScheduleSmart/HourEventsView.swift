//
//  HourEventsView.swift
//  ScheduleSmart
//
//  Created by Saketh Ogirala on 6/30/24.
//

import Foundation
import SwiftUI
import EventKit

struct HourEventsView: View {
    let hours: [String] = Array(0...23).map { String(format: "%02d:00", $0) }
    let events: [EKEvent]
    let selectedDate: Date?
    
    var body: some View {
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
                            ForEach(events) { event in
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
    }
}
