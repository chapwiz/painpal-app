//
//  Models.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import Foundation
import SwiftData

@Model final class Session {
    var childName: String
    var dateOfBirth: Date? = nil
    var createdAt: Date = Date()
    var isDeleted: Bool = false
    var deletedAt: Date? = nil

    @Relationship(deleteRule: .cascade, inverse: \PainEntry.session)
    var entries: [PainEntry] = []

    var activeEntries: [PainEntry] { entries.filter { !$0.isDeleted } }
    var deletedEntries: [PainEntry] { entries.filter { $0.isDeleted } }

    init(
        childName: String,
        dateOfBirth: Date? = nil,
        createdAt: Date = Date(),
        isDeleted: Bool = false,
        deletedAt: Date? = nil
    ) {
        self.childName = childName
        self.dateOfBirth = dateOfBirth
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


    // Age components (years, months) computed from dateOfBirth as of referenceDate.
    func ageComponents(asOf referenceDate: Date = Date()) -> DateComponents? {
        guard let dob = dateOfBirth else { return nil }
        return Calendar.current.dateComponents([.year, .month], from: dob, to: referenceDate)
    }

    var ageYears: Int? { ageComponents()?.year }
    var ageMonths: Int? { ageComponents()?.month }

    var ageDisplay: String? {
        guard let comps = ageComponents() else { return nil }
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        switch (y, m) {
        case (0, 0):
            return "<1 month"
        case (0, let mm):
            return "\(mm) month\(mm == 1 ? "" : "s")"
        case (let yy, 0):
            return "\(yy) year\(yy == 1 ? "" : "s")"
        default:
            return "\(y) year\(y == 1 ? "" : "s"), \(m) month\(m == 1 ? "" : "s")"
        }
    }

    // Static helper used by UI (e.g., New Session sheet) without needing a Session instance.
    static func ageString(for dob: Date, referenceDate: Date = Date()) -> String? {
        let comps = Calendar.current.dateComponents([.year, .month], from: dob, to: referenceDate)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        switch (y, m) {
        case (0, 0):
            return "<1 month"
        case (0, let mm):
            return "\(mm) month\(mm == 1 ? "" : "s")"
        case (let yy, 0):
            return "\(yy) year\(yy == 1 ? "" : "s")"
        default:
            return "\(y) year\(y == 1 ? "" : "s"), \(m) month\(m == 1 ? "" : "s")"
        }
    }
}

@Model final class PainEntry {
    var timestamp: Date
    var scale: PainScale
    var score: Int
    var notes: String
    var transcript: String?
    var aiSummary: String?

    var isDeleted: Bool = false
    var deletedAt: Date? = nil

    // Structured pain details
    var trend: String = "Same"   // Better / Same / Worse

    var durationMinutes: Int = 0

    // Multi-select fields (stored as transformable arrays)
    var locations: [String] = []
    var qualityWords: [String] = []
    var symptoms: [String] = []
    var triggers: [String] = []
    var relievers: [String] = []

    var session: Session?

    init(
        scale: PainScale,
        score: Int,
        notes: String,
        timestamp: Date = Date(),
        transcript: String? = nil,
        aiSummary: String? = nil,
        trend: String = "Same",
        durationMinutes: Int = 0,
        locations: [String] = [],
        qualityWords: [String] = [],
        symptoms: [String] = [],
        triggers: [String] = [],
        relievers: [String] = [],
        session: Session? = nil
    ) {
        self.scale = scale
        self.score = score
        self.notes = notes
        self.timestamp = timestamp
        self.transcript = transcript
        self.aiSummary = aiSummary

        self.trend = trend
        self.durationMinutes = durationMinutes
        self.locations = locations
        self.qualityWords = qualityWords
        self.symptoms = symptoms
        self.triggers = triggers
        self.relievers = relievers

        self.session = session
        self.isDeleted = false
        self.deletedAt = nil
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
