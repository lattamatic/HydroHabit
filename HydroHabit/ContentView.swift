//
//  ContentView.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    // This flag is stored on the phone. It's faster than the database for UI switching.
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @Query var profiles: [UserProfile]
    
    var body: some View {
        if !hasOnboarded || profiles.isEmpty {
            OnboardingView()
        } else {
            MainDashboardView()
        }
    }
}
