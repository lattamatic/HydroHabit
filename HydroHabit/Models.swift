//
//  Models.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//
import Foundation
import SwiftData

@Model
class UserProfile {
    var weight: Double
    var height: Double
    var age: Int
    var dailyGoal: Double
    
    // Times
    var wakeUpTime: Date
    var sleepTime: Date
    var breakfastTime: Date?
    var lunchTime: Date?
    var dinnerTime: Date?
    
    init(weight: Double, height: Double, age: Int, wake: Date, sleep: Date, breakfast: Date?, lunch: Date?, dinner: Date?) {
        self.weight = weight
        self.height = height
        self.age = age
        self.wakeUpTime = wake
        self.sleepTime = sleep
        self.breakfastTime = breakfast
        self.lunchTime = lunch
        self.dinnerTime = dinner
        // Calculation: 35ml per kg of body weight
        self.dailyGoal = weight * 35
    }
}

@Model
class WaterEntry {
    var id: UUID
    var date: Date
    var amount: Double // In ml
    
    init(amount: Double) {
        self.id = UUID()
        self.date = Date()
        self.amount = amount
    }
}
