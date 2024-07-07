//
//  EventCreationView.swift
//  ScheduleSmart
//
//  Created by Rithwik Pulicherla on 7/2/24.
//

import Foundation
import SwiftUI
import EventKit

struct EventCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var errorMessage: String? = nil
    
    let eventStore: EKEventStore

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Start Date", selection: $startDate)
                    DatePicker("End Date", selection: $endDate)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Add Event") {
                        addEvent()
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func addEvent() {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(newEvent, span: .thisEvent)
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "Failed to save event: \(error.localizedDescription)"
        }
    }
}
