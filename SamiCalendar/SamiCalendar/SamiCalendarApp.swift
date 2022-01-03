//
//  SamiCalendarApp.swift
//  SamiCalendar
//
//  Created by Hunasimarad, Samiulla on 09/12/21.
//

import SwiftUI

@main
struct SamiCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            CalendarWeekView(calendar: Calendar(identifier: .gregorian), selectedDate: Date())
        }
    }
}
