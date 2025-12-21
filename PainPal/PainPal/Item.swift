//
//  Item.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
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
