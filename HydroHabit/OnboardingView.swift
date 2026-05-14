import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    // This flag is the "Switch" that ContentView is watching
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    @State private var name: String = ""
    @State private var weight: Double = 75
    @State private var height: Double = 175
    @State private var age: Int = 25
    
    // Schedule
    @State private var wake = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
    @State private var sleep = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    
    // Meals
    @State private var hasBreakfast = true
    @State private var breakfastTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @State private var hasLunch = true
    @State private var lunchTime = Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date())!
    @State private var hasDinner = true
    @State private var dinnerTime = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!

    var body: some View {
        NavigationStack {
            Form {
                Section("About You") {
                    TextField("Your Name", text: $name)
                    Stepper("Weight: \(Int(weight)) kg", value: $weight, in: 30...200)
                    Stepper("Height: \(Int(height)) cm", value: $height, in: 100...250)
                }
                
                Section("Daily Schedule") {
                    DatePicker("Wake Up", selection: $wake, displayedComponents: .hourAndMinute)
                    DatePicker("Sleep", selection: $sleep, displayedComponents: .hourAndMinute)
                }
                
                Section("Meal Times (Optional)") {
                    Toggle("Breakfast", isOn: $hasBreakfast)
                    if hasBreakfast { DatePicker("Time", selection: $breakfastTime, displayedComponents: .hourAndMinute) }
                    
                    Toggle("Lunch", isOn: $hasLunch)
                    if hasLunch { DatePicker("Time", selection: $lunchTime, displayedComponents: .hourAndMinute) }
                    
                    Toggle("Dinner", isOn: $hasDinner)
                    if hasDinner { DatePicker("Time", selection: $dinnerTime, displayedComponents: .hourAndMinute) }
                }
                
                Section {
                    Button(action: saveProfile) {
                        Text("Finish Setup").frame(maxWidth: .infinity).bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
                    
                    Button(action: launchDemo) {
                        VStack(spacing: 4) {
                            Text("Try Demo Mode 🚀").bold()
                            Text("Loads historical data for a test user").font(.caption2)
                        }.frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered).tint(.orange)
                }
            }
            .navigationTitle("Profile Setup")
        }
    }
    
    func saveProfile() {
        print("DEBUG: Saving Primary Profile...")
        let p = UserProfile(
            name: name, weight: weight, height: height, age: age,
            wake: wake, sleep: sleep,
            breakfast: hasBreakfast ? breakfastTime : nil,
            lunch: hasLunch ? lunchTime : nil,
            dinner: hasDinner ? dinnerTime : nil
        )
        modelContext.insert(p)
        
        // Force Save and flip the switch
        try? modelContext.save()
        HydrationManager.shared.scheduleReminders(for: p)
        
        DispatchQueue.main.async {
            self.hasOnboarded = true
        }
    }
    
    func launchDemo() {
        print("DEBUG: Launching Demo Mode...")
        let demo = UserProfile(name: "Demo User", weight: 85, height: 185, age: 30, wake: Date(), sleep: Date(), isDemo: true)
        modelContext.insert(demo)
        
        let calendar = Calendar.current
        for i in 0...14 {
            let pastDate = calendar.date(byAdding: .day, value: -i, to: Date())!
            for _ in 1...10 {
                let e = WaterEntry(amount: 250, date: pastDate, user: demo)
                modelContext.insert(e)
            }
        }
        
        try? modelContext.save()
        HydrationManager.shared.scheduleReminders(for: demo)
        
        // Use DispatchQueue to ensure the UI updates on the main thread
        DispatchQueue.main.async {
            self.hasOnboarded = true
        }
    }
}
