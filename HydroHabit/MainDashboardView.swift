import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    // Fetch all profiles to allow switching
    @Query(sort: \UserProfile.name) var allProfiles: [UserProfile]
    
    // State for UI control
    @State private var activeProfileID: UUID?
    @State private var showingHistory = false
    
    // Identify the user we are currently looking at
    var activeProfile: UserProfile? {
        if let id = activeProfileID {
            return allProfiles.first(where: { $0.id == id })
        }
        return allProfiles.first(where: { !$0.isDemo }) ?? allProfiles.first
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                if let profile = activeProfile {
                    
                    // 1. PROFILE INDICATOR
                    HStack {
                        Text(profile.isDemo ? "DEMO MODE" : "PRIMARY USER")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(profile.isDemo ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                            .foregroundColor(profile.isDemo ? .orange : .blue)
                            .cornerRadius(20)
                        
                        if profile.isDemo {
                            Text("Showing Dummy Data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 10)

                    // 2. THE 3D TAPERED GLASS
                    let entries = profile.waterEntries ?? []
                    let todayTotal = entries.filter { Calendar.current.isDateInToday($0.date) }
                        .reduce(0) { $0 + $1.amount }
                    let progress = todayTotal / profile.dailyGoal
                    
                    WaterGlassView(progress: progress)
                        .padding(.vertical, 20)
                    
                    // 3. MAIN STATS
                    VStack(spacing: 5) {
                        Text("\(Int(todayTotal))ml")
                            .font(.system(size: 54, weight: .black, design: .rounded))
                            .foregroundColor(.blue)
                        
                        Text("Target: \(Int(profile.dailyGoal))ml")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        let remaining = max(profile.dailyGoal - todayTotal, 0)
                        if remaining > 0 {
                            Text("\(Int(remaining))ml remaining to reach goal")
                                .font(.caption)
                                .padding(.top, 5)
                        } else {
                            Text("Goal Achieved! 🎉")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                                .padding(.top, 5)
                        }
                    }
                    
                    Spacer()
                    
                    // 4. ACTION BUTTONS
                    VStack(spacing: 16) {
                        Button(action: { addWater(to: profile) }) {
                            HStack {
                                Image(systemName: "drop.fill")
                                Text("Add 250ml Glass")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(18)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(action: { showingHistory = true }) {
                            Text("View Monthly Progress & Stats")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Hydro Habit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Switch Active Profile") {
                            ForEach(allProfiles) { p in
                                Button {
                                    activeProfileID = p.id
                                } label: {
                                    HStack {
                                        Text(p.name + (p.isDemo ? " (Demo)" : ""))
                                        if activeProfile?.id == p.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section("Management") {
                            Button(role: .destructive, action: resetApp) {
                                Label("Clear All Data", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                if let profile = activeProfile {
                    MonthlyDashboardView(profile: profile)
                }
            }
        }
    }

    func addWater(to profile: UserProfile) {
        let newEntry = WaterEntry(amount: 250, date: Date(), user: profile)
        modelContext.insert(newEntry)
        try? modelContext.save()
    }
    
    func resetApp() {
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.delete(model: WaterEntry.self)
        try? modelContext.save()
        hasOnboarded = false
        activeProfileID = nil
    }
}

// MARK: - MONTHLY HISTORY & STATS DASHBOARD
struct MonthlyDashboardView: View {
    var profile: UserProfile
    @State private var selectedMonth = Date()
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 1. MONTH SELECTOR
                    HStack {
                        Button(action: { moveMonth(-1) }) {
                            Image(systemName: "chevron.left.circle.fill").font(.title2)
                        }
                        Spacer()
                        Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                            .font(.title3.bold())
                        Spacer()
                        Button(action: { moveMonth(1) }) {
                            Image(systemName: "chevron.right.circle.fill").font(.title2)
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // 2. CALENDAR GRID
                    VStack(spacing: 10) {
                        // Weekday Headers
                        HStack {
                            ForEach(weekdays, id: \.self) { day in
                                Text(day).font(.caption.bold()).frame(maxWidth: .infinity).foregroundColor(.secondary)
                            }
                        }
                        
                        let days = generateDaysInMonth()
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(0..<days.count, id: \.self) { index in
                                if let date = days[index] {
                                    let met = hasMetGoal(for: date)
                                    VStack {
                                        Text("\(calendar.component(.day, from: date))")
                                            .font(.caption2)
                                            .foregroundColor(calendar.isDateInToday(date) ? .blue : .primary)
                                        
                                        Image(systemName: met ? "drop.fill" : "drop")
                                            .font(.title2)
                                            .foregroundColor(met ? .blue : .blue.opacity(0.15))
                                    }
                                    .frame(height: 50)
                                } else {
                                    Color.clear.frame(height: 50)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.secondary.opacity(0.05)))
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // 3. THE LARGE STATS DASHBOARD (Fills the white space)
                    let stats = calculateMonthlyStats()
                    VStack(spacing: 15) {
                        Text("MONTHLY ACHIEVEMENT")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("\(stats.met)")
                                .font(.system(size: 90, weight: .black, design: .rounded))
                                .foregroundColor(.blue)
                            Text("/\(stats.total)")
                                .font(.title.bold())
                                .foregroundColor(.secondary)
                        }
                        
                        Text("DAYS TARGET MET")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Large Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(height: 20)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * CGFloat(Double(stats.met) / Double(stats.total)), height: 20)
                            }
                        }
                        .frame(height: 20)
                        .padding(.horizontal, 40)
                        
                        Text(stats.met == stats.total ? "Perfect streak! You are a hero! 🏆" : "Stay hydrated to fill the drops!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("History & Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss

    // CALENDAR LOGIC
    func moveMonth(_ value: Int) {
        if let nextMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = nextMonth
        }
    }

    func hasMetGoal(for date: Date) -> Bool {
        let dayEntries = (profile.waterEntries ?? []).filter { calendar.isDate($0.date, inSameDayAs: date) }
        let total = dayEntries.reduce(0) { $0 + $1.amount }
        return total >= profile.dailyGoal
    }

    func generateDaysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else { return [] }
        
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = weekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    func calculateMonthlyStats() -> (met: Int, total: Int) {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else { return (0, 0) }
        
        var metCount = 0
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                if hasMetGoal(for: date) {
                    metCount += 1
                }
            }
        }
        return (metCount, range.count)
    }
}
