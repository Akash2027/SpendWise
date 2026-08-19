//
//  Item.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
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
