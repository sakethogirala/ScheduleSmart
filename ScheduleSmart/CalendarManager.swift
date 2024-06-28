import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var events: [EKEvent] = []
    
    func requestAccess() {
        eventStore.requestFullAccessToEvents { granted, error in
            if granted {
                self.loadEvents()
            }
        }
    }
    
    private func loadEvents() {
        let calendars = eventStore.calendars(for: .event)
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfMonth, end: endOfMonth, calendars: calendars)
        
        DispatchQueue.main.async {
            self.events = self.eventStore.events(matching: predicate)
        }
    }
}
