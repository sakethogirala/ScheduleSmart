//
//  CalendarView.swift
//  ScheduleSmart
//
//  Created by Saketh Ogirala on 6/28/24.
//

import Foundation
import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    let calendar = FSCalendar()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        calendar.dataSource = context.coordinator
        calendar.delegate = context.coordinator
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.todayColor = .orange
        calendar.appearance.selectionColor = .blue
        calendar.allowsMultipleSelection = false
        view.addSubview(calendar)
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        calendar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        calendar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the selected date in the calendar
        if let selectedDate = selectedDate {
            calendar.select(selectedDate)
            calendar.setCurrentPage(selectedDate, animated: true)
        } else {
            if let selectedDate = calendar.selectedDate {
                calendar.deselect(selectedDate)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDataSource, FSCalendarDelegate {
        var parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
    }
}
