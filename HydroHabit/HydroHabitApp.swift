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
    
    init() {
        HydrationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [UserProfile.self, WaterEntry.self])
    }
}
