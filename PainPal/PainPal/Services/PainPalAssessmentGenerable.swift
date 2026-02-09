//
//  PainPalAssessmentGenerable.swift
//  PainPal
//
//  Created by Chapman Leung on 28/1/2026.
//

import FoundationModels

@Generable
struct SessionSummary {
    var childName: String
    var ageYears: Int?
    var ageMonths: Int?

    var scoreSeriesLatestToOldest: [Int]
    var trend: String?                 // "worsening" | "improving" | "stable" | "unclear"
    var commonLocations: [String]
    var commonSymptoms: [String]
    var commonTriggers: [String]
    var commonRelievers: [String]
    var notableChanges: [String]
    var clinicianTimeline: String
}

@Generable
struct TrendSummary {
    var childName: String
    var ageYears: Int?
    var ageMonths: Int?

    /// Latest-to-oldest pain scores extracted from the note (empty if not present).
    var scoreSeriesLatestToOldest: [Int]

    /// One of: "worsening", "improving", "stable", "unclear".
    var trend: String

    var commonLocations: [String]
    var commonSymptoms: [String]
    var commonTriggers: [String]
    var commonRelievers: [String]

    /// Potential urgent symptoms/signs mentioned (do not diagnose).
    var redFlags: [String]

    /// A concise, clinician-friendly paragraph summarising pattern + changes.
    var oneParagraphSummary: String

    /// Focused follow-up questions if information is missing.
    var questionsToAskNext: [String]
}

@Generable
struct PainPalAssessment {
    @Generable
    struct Child {
        var name: String
        var ageYears: Int?
        var ageMonths: Int?
    }

    @Generable
    struct Pain {
        var currentScore0to10: Int?
        var trend: String
        var locations: [String]
        var qualityWords: [String]
        var onset: String
        var duration: String
        var triggers: [String]
        var relievers: [String]
    }

    var child: Child
    var pain: Pain
    var associatedSymptoms: [String]
    var redFlagsDetected: [String]
    var dangerLevel: String
    var whyThisLevel: String
    var recommendedNextStep: String
    var questionsToAskNext: [String]
    var clinicianSummary: String
}
