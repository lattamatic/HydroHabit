//
//  Item.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
