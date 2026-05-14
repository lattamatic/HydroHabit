//
//  OnboardingView.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var weight: Double = 70
    @State private var height: Double = 170
    @State private var age: Int = 25
    @State private var wake = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
    @State private var sleep = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Body Stats") {
                    Stepper("Weight: \(Int(weight)) kg", value: $weight, in: 30...200)
                    Stepper("Height: \(Int(height)) cm", value: $height, in: 100...250)
                    Stepper("Age: \(age)", value: $age, in: 1...100)
                }
                
                Section("Schedule") {
                    DatePicker("Wake Up", selection: $wake, displayedComponents: .hourAndMinute)
                    DatePicker("Sleep", selection: $sleep, displayedComponents: .hourAndMinute)
                }
                
                Button("Create Profile") {
                    let newProfile = UserProfile(weight: weight, height: height, age: age, wake: wake, sleep: sleep, breakfast: nil, lunch: nil, dinner: nil)
                    modelContext.insert(newProfile)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Your Profile")
        }
    }
    
    func loadDemoProfile() {
        // 1. Create the Profile
        let demoProfile = UserProfile(
            weight: 80, height: 180, age: 30,
            wake: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!,
            sleep: Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!,
            breakfast: Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!,
            lunch: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date())!,
            dinner: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        )
        modelContext.insert(demoProfile)
        
        // 2. Generate 7 days of "Completed" water entries
        let calendar = Calendar.current
        for dayOffset in 1...7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            // Add 10 glasses (2500ml) to each day so the goal is met
            for _ in 1...10 {
                let entry = WaterEntry(amount: 250)
                entry.date = date // Set the historical date
                modelContext.insert(entry)
            }
        }
    }
}
