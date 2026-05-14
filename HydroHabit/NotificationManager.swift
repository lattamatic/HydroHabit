//
//  NotificationManager.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    func scheduleReminders(for profile: UserProfile) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // We want to remind every 90 minutes
        let reminderInterval: TimeInterval = 90 * 60
        var currentTime = profile.wakeUpTime
        
        while currentTime < profile.sleepTime {
            // Check if this time is NOT near a meal (45 min buffer)
            if !isNearMeal(time: currentTime, profile: profile) {
                scheduleOne(at: currentTime)
            }
            currentTime.addTimeInterval(reminderInterval)
        }
    }
    
    private func isNearMeal(time: Date, profile: UserProfile) -> Bool {
        let meals = [profile.breakfastTime, profile.lunchTime, profile.dinnerTime].compactMap { $0 }
        for meal in meals {
            let diff = abs(time.timeIntervalSince(meal))
            if diff < (45 * 60) { return true } // Too close to a meal
        }
        return false
    }
    
    private func scheduleOne(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Hydration Time 💧"
        content.body = "Time for a 250ml glass of water."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
