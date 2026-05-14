import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    @State private var name: String = ""
    @State private var weight: Double = 75
    @State private var height: Double = 175
    @State private var age: Int = 25
    
    @State private var wake = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
    @State private var sleep = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!

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
                
                Section {
                    Button(action: saveProfile) {
                        Text("Finish Setup").frame(maxWidth: .infinity).bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
                    
                    Button(action: launchDemo) {
                        VStack(spacing: 4) {
                            Text("Try Demo Mode 🚀").bold()
                            Text("12/15 days target reached").font(.caption2)
                        }.frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered).tint(.orange)
                }
            }
            .navigationTitle("Profile Setup")
        }
    }
    
    func saveProfile() {
        let p = UserProfile(name: name, weight: weight, height: height, age: age, wake: wake, sleep: sleep, isDemo: false)
        modelContext.insert(p)
        finish(p)
    }
    
    func launchDemo() {
        let demo = UserProfile(name: "John Doe", weight: 80, height: 180, age: 30, wake: Date(), sleep: Date(), isDemo: true)
        modelContext.insert(demo)
        
        let calendar = Calendar.current
        // Create 15 days of history
        var dayOffsets = Array(0...14)
        dayOffsets.shuffle()
        
        // Pick 3 random days to be "Fail" days
        let failDays = Array(dayOffsets.prefix(3))
        
        for i in 0...14 {
            let pastDate = calendar.date(byAdding: .day, value: -i, to: Date())!
            let isFailDay = failDays.contains(i)
            
            // If fail, add only 2 glasses (500ml). If success, add 12 (3000ml).
            let glassCount = isFailDay ? 2 : 12
            
            for _ in 1...glassCount {
                let e = WaterEntry(amount: 250, date: pastDate, user: demo)
                modelContext.insert(e)
            }
        }
        finish(demo)
    }
    
    func finish(_ p: UserProfile) {
        try? modelContext.save()
        HydrationManager.shared.scheduleReminders(for: p)
        DispatchQueue.main.async { self.hasOnboarded = true }
    }
}
