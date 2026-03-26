//
//  UserRole.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import Foundation

enum UserRole: String, CaseIterable, Identifiable, Codable {
    case parent
    case caregiver
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .parent:
            return "Parent / Guardian"
        case .caregiver:
            return "Caregiver / Professional"
        }
    }
    
    var subtitle: String {
        switch self {
        case .parent:
            return "Best for one or two children with quicker access to recording and recent history."
        case .caregiver:
            return "Best for managing multiple children and switching between records."
        }
    }
    
    var iconName: String {
        switch self {
        case .parent:
            return "heart.text.square"
        case .caregiver:
            return "person.2"
        }
    }
}
