//
//  HydrationManager.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//
import Foundation
import UserNotifications

class HydrationManager {
    static let shared = HydrationManager()
    
    // 1. Request Permission to send alerts
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("DEBUG: Notification permission granted.")
            } else if let error = error {
                print("DEBUG: Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    // 2. The core logic to schedule the reminders
    func scheduleReminders(for profile: UserProfile) {
        let center = UNUserNotificationCenter.current()
        
        // Remove old notifications before setting new ones
        center.removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        let wakeTime = profile.wakeUpTime
        let sleepTime = profile.sleepTime
        
        // Default meal times if user skipped them
        let breakfast = profile.breakfastTime ?? calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let lunch = profile.lunchTime ?? calendar.date(bySettingHour: 13, minute: 0, second: 0, of: Date())!
        let dinner = profile.dinnerTime ?? calendar.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
        
        let meals = [breakfast, lunch, dinner]
        
        // How often to remind? Let's say every 90 minutes.
        let interval: TimeInterval = 90 * 60
        
        var currentPoint = wakeTime
        
        // Loop from Wake time to Sleep time
        while currentPoint < sleepTime {
            
            // Check if currentPoint is in a "No-Drink Zone" (45 mins after a meal)
            var isHealthyTime = true
            for meal in meals {
                let timeSinceMeal = currentPoint.timeIntervalSince(meal)
                // If we are within 45 minutes AFTER the meal start time
                if timeSinceMeal >= 0 && timeSinceMeal < (45 * 60) {
                    isHealthyTime = false
                }
            }
            
            // If it's a healthy time, schedule it!
            if isHealthyTime {
                scheduleLocalNotification(at: currentPoint)
            }
            
            // Advance the clock by 90 minutes
            currentPoint.addTimeInterval(interval)
        }
        
        print("DEBUG: Notifications scheduled successfully.")
    }
    
    private func scheduleLocalNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Drink Water 💧"
        content.body = "Keep your glass full! It's time for another 250ml."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
