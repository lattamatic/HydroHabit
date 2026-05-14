//
//  ContentView.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // This asks the database: "Are there any profiles?"
    @Query var profiles: [UserProfile]
    
    var body: some View {
        if let profile = profiles.first {
            // If a profile is found, show the Dashboard
            MainDashboardView(profile: profile)
        } else {
            // If the database is empty, show the Setup screen
            OnboardingView()
        }
    }
}
