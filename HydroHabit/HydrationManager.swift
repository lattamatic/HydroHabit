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
    
    func scheduleReminders(user: UserProfile) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let interval = 2.0 // Hours between reminders
        var currentPoint = user.wakeUpTime
        
        while currentPoint < user.sleepTime {
            // Check if currentPoint is within 45 mins of a meal
            if !isDuringMeal(time: currentPoint, user: user) {
                scheduleNotification(at: currentPoint)
            }
            currentPoint = currentPoint.addingTimeInterval(interval * 3600)
        }
    }
    
    private func isDuringMeal(time: Date, user: UserProfile) -> Bool {
        let mealTimes = [user.breakfastTime, user.lunchTime, user.dinnerTime].compactMap { $0 }
        for meal in mealTimes {
            let diff = abs(time.timeIntervalSince(meal))
            if diff < 2700 { return true } // 45 mins = 2700 seconds
        }
        return false
    }
    
    private func scheduleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Drink!"
        content.body = "Have a 250ml glass of water to stay on track."
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
