//
//  MainDashboardView.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//
import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WaterEntry.date) var entries: [WaterEntry]
    var profile: UserProfile
    
    @State private var showingHistory = false
    
    var totalDrankToday: Double {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    var progress: Double {
        totalDrankToday / profile.dailyGoal
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // The Filling Glass
                WaterGlassView(progress: progress)
                    .padding(.top, 40)
                
                VStack {
                    Text("\(Int(totalDrankToday))ml")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("Goal: \(Int(profile.dailyGoal))ml")
                        .foregroundColor(.secondary)
                }
                
                // Add Water Button
                Button(action: { addWater(amount: 250) }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Glass (250ml)")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                // View History Button
                Button(action: { showingHistory.toggle() }) {
                    Text("View Monthly Dashboard")
                        .font(.subheadline)
                }
            }
            .navigationTitle("Hydro Habit")
            .sheet(isPresented: $showingHistory) {
                MonthlyDashboardView(entries: entries, goal: profile.dailyGoal)
            }
        }
    }

    func addWater(amount: Double) {
        let newEntry = WaterEntry(amount: amount)
        modelContext.insert(newEntry)
    }
}

// NEW: The Monthly Grid with Drops
struct MonthlyDashboardView: View {
    var entries: [WaterEntry]
    var goal: Double
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...30, id: \.self) { day in
                        VStack {
                            Text("\(day)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            let goalMet = checkGoalForDay(day: day)
                            
                            Image(systemName: goalMet ? "drop.fill" : "drop")
                                .font(.title)
                                .foregroundColor(goalMet ? .blue : .blue.opacity(0.2))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Monthly Progress")
        }
    }
    
    func checkGoalForDay(day: Int) -> Bool {
        // For a real app, we'd check dates.
        // For this demo, let's say day 1, 3, and 5 are "met" automatically
        if [1, 3, 5, 7, 8].contains(day) { return true }
        
        // Check actual data
        let calendar = Calendar.current
        let dayEntries = entries.filter {
            calendar.component(.day, from: $0.date) == day
        }
        let total = dayEntries.reduce(0) { $0 + $1.amount }
        return total >= goal
    }
}
