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
    var id: UUID = UUID()
    var name: String
    var isDemo: Bool = false
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
    
    @Relationship(deleteRule: .cascade, inverse: \WaterEntry.user)
    var waterEntries: [WaterEntry]? = []
    
    init(name: String, weight: Double, height: Double, age: Int, wake: Date, sleep: Date,
         breakfast: Date? = nil, lunch: Date? = nil, dinner: Date? = nil, isDemo: Bool = false) {
        self.id = UUID()
        self.name = name
        self.weight = weight
        self.height = height
        self.age = age
        self.wakeUpTime = wake
        self.sleepTime = sleep
        self.breakfastTime = breakfast
        self.lunchTime = lunch
        self.dinnerTime = dinner
        self.isDemo = isDemo
        self.dailyGoal = weight * 35
    }
}

@Model
class WaterEntry {
    var id: UUID = UUID()
    var date: Date
    var amount: Double
    var user: UserProfile?
    
    init(amount: Double, date: Date = Date(), user: UserProfile? = nil) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.user = user
    }
}
