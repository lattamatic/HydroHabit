import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    @Query(sort: \UserProfile.name) var allProfiles: [UserProfile]
    @State private var activeProfileID: UUID?
    @State private var showingHistory = false
    
    // Automatically picks the first non-demo user, or the one you selected
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
                    
                    // Profile Banner
                    HStack {
                        Text(profile.isDemo ? "DEMO MODE" : "PRIMARY USER")
                            .font(.caption.bold())
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(profile.isDemo ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                            .foregroundColor(profile.isDemo ? .orange : .blue)
                            .cornerRadius(20)
                    }

                    let entries = profile.waterEntries ?? []
                    let todayTotal = entries.filter { Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.amount }
                    
                    WaterGlassView(progress: todayTotal / profile.dailyGoal)
                    
                    VStack(spacing: 5) {
                        Text("\(Int(todayTotal))ml").font(.system(size: 54, weight: .black, design: .rounded)).foregroundColor(.blue)
                        Text("Target: \(Int(profile.dailyGoal))ml").font(.title3).foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: { addWater(to: profile) }) {
                            Label("Add 250ml Glass", systemImage: "drop.fill")
                                .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(Color.blue).foregroundColor(.white).cornerRadius(18)
                        }
                        
                        Button("View Monthly History") { showingHistory = true }.font(.subheadline.bold())
                    }
                    .padding(.horizontal, 40).padding(.bottom, 30)
                } else {
                    Text("No Profile Found").onAppear { hasOnboarded = false }
                }
            }
            .navigationTitle("Hydro Habit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Active Profile") {
                            ForEach(allProfiles) { p in
                                Button {
                                    activeProfileID = p.id
                                } label: {
                                    HStack {
                                        Text(p.name + (p.isDemo ? " (Demo)" : ""))
                                        if activeProfile?.id == p.id { Image(systemName: "checkmark") }
                                    }
                                }
                            }
                        }
                        
                        Section("Actions") {
                            Button(role: .destructive, action: resetApp) {
                                Label("Clear All & Logout", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "gearshape.fill").font(.title3).foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                if let profile = activeProfile { MonthlyDashboardView(profile: profile) }
            }
        }
    }

    func addWater(to profile: UserProfile) {
        modelContext.insert(WaterEntry(amount: 250, date: Date(), user: profile))
        try? modelContext.save()
    }
    
    func resetApp() {
        allProfiles.forEach { modelContext.delete($0) }
        try? modelContext.save()
        hasOnboarded = false
        activeProfileID = nil
    }
}

// THE MONTHLY HISTORY VIEW
struct MonthlyDashboardView: View {
    @Environment(\.dismiss) var dismiss
    var profile: UserProfile
    @State private var selectedMonth = Date()
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: { moveMonth(-1) }) { Image(systemName: "chevron.left") }
                        Spacer()
                        Text(selectedMonth.formatted(.dateTime.month(.wide).year())).font(.headline)
                        Spacer()
                        Button(action: { moveMonth(1) }) { Image(systemName: "chevron.right") }
                    }.padding()

                    let days = generateDays()
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(0..<days.count, id: \.self) { i in
                            if let date = days[i] {
                                let met = hasMetGoal(for: date)
                                VStack {
                                    Text("\(calendar.component(.day, from: date))").font(.caption2).foregroundColor(.secondary)
                                    Image(systemName: met ? "drop.fill" : "drop")
                                        .font(.title2).foregroundColor(met ? .blue : .blue.opacity(0.15))
                                }
                            } else { Color.clear.frame(height: 40) }
                        }
                    }.padding(.horizontal)

                    Divider().padding()

                    let stats = calculateStats()
                    VStack(spacing: 10) {
                        Text("MONTHLY ACHIEVEMENT").font(.caption.bold()).foregroundColor(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("\(stats.met)").font(.system(size: 80, weight: .black, design: .rounded)).foregroundColor(.blue)
                            Text("/\(stats.total)").font(.title.bold()).foregroundColor(.secondary)
                        }
                        ProgressView(value: Double(stats.met), total: Double(stats.total))
                            .tint(.blue).scaleEffect(x: 1, y: 3).padding(.horizontal, 50)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    func moveMonth(_ v: Int) { selectedMonth = calendar.date(byAdding: .month, value: v, to: selectedMonth) ?? selectedMonth }
    
    func hasMetGoal(for d: Date) -> Bool {
        let total = (profile.waterEntries ?? []).filter { calendar.isDate($0.date, inSameDayAs: d) }.reduce(0) { $0 + $1.amount }
        return total >= profile.dailyGoal
    }

    func generateDays() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else { return [] }
        let offset = calendar.component(.weekday, from: first) - 1
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range { days.append(calendar.date(byAdding: .day, value: day-1, to: first)) }
        return days
    }

    func calculateStats() -> (met: Int, total: Int) {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let start = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else { return (0, 0) }
        var count = 0
        for d in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: d, to: start), hasMetGoal(for: date) { count += 1 }
        }
        return (count, range.count)
    }
}
