//
//  AuthenticatedUser.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import Foundation

struct AuthenticatedUser: Codable, Equatable {
    let id: String
    let appleSubject: String
    let email: String?
    let role: UserRole
}
