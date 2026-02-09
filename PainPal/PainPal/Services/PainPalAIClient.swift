//
//  PainPalAIClient.swift
//  PainPal
//
//  Created by Chapman Leung on 28/1/2026.
//

import Foundation
import FoundationModels

// Minimal AI client:
// 1) Summarise recent records into a TrendSummary.
// 2) Assess red flags / next steps into a PainPalAssessment.
//
// Note: This does NOT diagnose. It is safety-first and only uses provided notes.
@MainActor
final class PainPalAIClient {
    private let trendSession: LanguageModelSession
    private let triageSession: LanguageModelSession

    init() {
        trendSession = LanguageModelSession(instructions: """
        You are PainPal Trends.
        You summarise recent pain records for clinicians.
        You are NOT a doctor.

        OUTPUT REQUIREMENTS
        - Return output that matches the TrendSummary schema exactly.
        - Do not add extra keys/fields.
        - Do not include markdown or commentary.
        - Use only information provided in the caregiver note.
        - If missing/unknown, leave arrays empty and strings minimal (or "unclear" for trend).
        """)

        triageSession = LanguageModelSession(instructions: """
        You are PainPal, an assistant that helps caregivers describe a child’s pain for clinicians.
        You are NOT a doctor. You MUST be cautious and safety-first.

        GOAL
        1) Extract structured pain details from the caregiver notes.
        2) Identify any red flags and assign a dangerLevel for next steps.

        SAFETY RULES
        - Never diagnose. Never claim certainty.
        - Only use information provided in the notes; do not invent details.
        - Use general, non-alarming language, but clear about urgency.
        - If dangerLevel is "EMERGENCY" or "URGENT", advise seeking professional help immediately.
        - If breathing difficulty, blue lips, seizure, severe allergic reaction, sudden severe pain with serious symptoms,
          severe dehydration, altered consciousness, or head injury with concerning symptoms are present, set dangerLevel="EMERGENCY".
        - If unsure due to missing info, set dangerLevel="INSUFFICIENT_INFO" and ask focused questions.

        OUTPUT REQUIREMENTS
        - Return output that matches the PainPalAssessment schema exactly.
        - dangerLevel MUST be exactly one of: "EMERGENCY","URGENT","ROUTINE","INSUFFICIENT_INFO".
        - If unknown: use null for optional numbers and [] for arrays.
        - Do not add extra keys/fields.
        - Do not include markdown or commentary.
        """)
    }

    // MARK: - Public API

    func summariseTrend(from caregiverNote: String) async throws -> TrendSummary {
        let prompt = """
        You must output data in a stable, machine-storable format that matches the TrendSummary schema exactly.
        - Do NOT diagnose.
        - Use ONLY information present in the caregiver note.
        - Do NOT invent details.
        - If unknown: use [] for arrays, nulls for optional numbers, and trend="unclear".
        - trend MUST be one of: "worsening", "improving", "stable", "unclear".
        - Keep oneParagraphSummary concise and clinician-friendly.

        Caregiver note:
        \(caregiverNote)
        """

        let resp = try await trendSession.respond(
            to: prompt,
            generating: TrendSummary.self,
            options: GenerationOptions(sampling: .greedy)
        )
        return resp.content
    }

    // Assess red flags / urgency and produce a structured PainPalAssessment.
    // If a TrendSummary is provided, it will be included as context.
    func assess(from caregiverNote: String, trend: TrendSummary? = nil) async throws -> PainPalAssessment {
        let prompt: String
        if let trend {
            prompt = """
            Produce a PainPalAssessment object (structured output) that matches the schema exactly.
            - Do NOT diagnose.
            - Use ONLY information in the trend summary and caregiver note.
            - Do NOT invent details.
            - dangerLevel MUST be exactly one of: "EMERGENCY","URGENT","ROUTINE","INSUFFICIENT_INFO".
            - If unknown: use null or [].

            Trend paragraph:
            \(trend.oneParagraphSummary)

            Red flags mentioned:
            \(trend.redFlags.joined(separator: ", "))

            Caregiver note:
            \(caregiverNote)
            """
        } else {
            prompt = """
            Produce a PainPalAssessment object (structured output) that matches the schema exactly.
            - Do NOT diagnose.
            - Use ONLY information in the caregiver note.
            - Do NOT invent details.
            - dangerLevel MUST be exactly one of: "EMERGENCY","URGENT","ROUTINE","INSUFFICIENT_INFO".
            - If unknown: use null or [].

            Caregiver note:
            \(caregiverNote)
            """
        }

        let resp = try await triageSession.respond(
            to: prompt,
            generating: PainPalAssessment.self,
            options: GenerationOptions(sampling: .greedy)
        )
        return resp.content
    }

    // MARK: - Helpers

    private func prependChildContext(
        to caregiverNote: String,
        childName: String?,
        ageYears: Int?,
        ageMonths: Int?
    ) -> String {
        var parts: [String] = []
        if let childName, !childName.isEmpty {
            parts.append("Child: \(childName).")
        }
        if ageYears != nil || ageMonths != nil {
            let y = ageYears.map(String.init) ?? "unknown"
            let m = ageMonths.map(String.init) ?? "unknown"
            parts.append("AgeYears: \(y), AgeMonths: \(m).")
        }

        guard !parts.isEmpty else { return caregiverNote }
        return parts.joined(separator: " ") + "\n" + caregiverNote
    }
}
