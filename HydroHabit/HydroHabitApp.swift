//
//  HydroHabitApp.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//

import SwiftUI
import SwiftData

@main
struct HydroHabitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView() // This calls the code in your other file
        }
        .modelContainer(for: [UserProfile.self, WaterEntry.self])
    }
}
