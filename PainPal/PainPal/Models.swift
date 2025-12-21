//
//  Models.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import Foundation
import SwiftData

enum PainScale: String, CaseIterable, Identifiable, Codable {
    case wongBaker = "Wong-Baker"
    case rFLACC = "r-FLACC"
    var id: String { rawValue }
}

@Model final class Session {
    var childName: String
    var createdAt: Date = Date()
    var isDeleted: Bool = false
    var deletedAt: Date? = nil

    @Relationship(deleteRule: .cascade, inverse: \PainEntry.session)
    var entries: [PainEntry] = []

    init(childName: String, createdAt: Date = Date(), isDeleted: Bool = false, deletedAt: Date? = nil) {
        self.childName = childName
        self.createdAt = createdAt
        self.isDeleted = isDeleted
        self.deletedAt = deletedAt
    }

    func softDelete(at date: Date = Date()) {
        isDeleted = true
        deletedAt = date
    }

    func restore() {
        isDeleted = false
        deletedAt = nil
    }
}

@Model final class PainEntry {
    var timestamp: Date
    var scale: PainScale
    var score: Int
    var notes: String
    var transcript: String?
    var aiSummary: String?
    var session: Session?

    init(
        scale: PainScale,
        score: Int,
        notes: String,
        timestamp: Date = Date(),
        transcript: String? = nil,
        aiSummary: String? = nil,
        session: Session? = nil
    ) {
        self.scale = scale
        self.score = score
        self.notes = notes
        self.timestamp = timestamp
        self.transcript = transcript
        self.aiSummary = aiSummary
        self.session = session
    }
}
