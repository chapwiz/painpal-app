//
//  EntryNotificationBuilder.swift
//  PainPal
//
//  Created by Chapman Leung on 25/3/2026.
//

import Foundation

struct EntryNotificationBuilder {

    static func buildPlans(
        for entry: PainEntry,
        recentEntries: [PainEntry]
    ) -> [NotificationPlan] {
        // Combines all notification categories for a newly saved entry.
        // Each helper below is responsible for returning zero or more notification plans.
        var plans: [NotificationPlan] = []

        plans += medicineOutcomeFollowUp(for: entry)
        plans += hydrationPrompts(for: entry)
        plans += triggerLoggingPrompts(for: entry)
        plans += patternObservations(for: entry, recentEntries: recentEntries)
        plans += missingInformationReminders(for: entry)

        return plans
    }
}

private extension EntryNotificationBuilder {

    static func debugInterval(_ key: String, fallback: TimeInterval) -> TimeInterval {
        let value = UserDefaults.standard.double(forKey: key)
        return value > 0 ? value : fallback
    }

    static func sessionNameText(for entry: PainEntry) -> String {
        let rawName = entry.session?.childName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return rawName.isEmpty ? "the child" : rawName
    }

    static func notificationTitle(for entry: PainEntry) -> String {
        "PainPal - \(sessionNameText(for: entry))"
    }

    static func medicineOutcomeFollowUp(for entry: PainEntry) -> [NotificationPlan] {
        // Medicine follow-up notification:
        // Only created when medicine was logged and a non-empty medicine name exists.
        guard entry.medicineTaken,
              !entry.medicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return []
        }

        let sessionName = sessionNameText(for: entry)
        let title = notificationTitle(for: entry)

        // Debug: this notification should appear when medicineTaken == true and medicineName is filled in.
        return [
            NotificationPlan(
                id: "entry-\(String(describing: entry.id))-medicine-outcome",
                title: title,
                body: "You logged \(entry.medicineName) for \(sessionName). Please record whether it helped.",
                timeInterval: debugInterval("debugMedicineOutcomeInterval", fallback: 5)
            )
        ]
    }

    static func hydrationPrompts(for entry: PainEntry) -> [NotificationPlan] {
        // Hydration prompt notification:
        // Triggered for fever, vomiting, or nausea entries.
        let symptoms = Set(entry.symptoms.map { $0.lowercased() })
        let hydrationRelevant = symptoms.contains("fever")
            || symptoms.contains("vomiting")
            || symptoms.contains("nausea")

        // Debug: if this does not fire, check the exact symptom strings being stored in entry.symptoms.
        guard hydrationRelevant else { return [] }

        let sessionName = sessionNameText(for: entry)
        let title = notificationTitle(for: entry)

        // Debug: this should appear for any entry containing fever, vomiting, or nausea.
        return [
            NotificationPlan(
                id: "entry-\(String(describing: entry.id))-hydration",
                title: title,
                body: "Please encourage fluids for \(sessionName) and record whether hydration has improved.",
                timeInterval: debugInterval("debugHydrationInterval", fallback: 6)
            )
        ]
    }

    static func triggerLoggingPrompts(for entry: PainEntry) -> [NotificationPlan] {
        // Trigger logging prompt notification:
        // Triggered for headache, dizziness, or nausea when no triggers have been recorded yet.
        let symptoms = Set(entry.symptoms.map { $0.lowercased() })
        let shouldPrompt = symptoms.contains("headache")
            || symptoms.contains("dizziness")
            || symptoms.contains("nausea")

        let hasTriggers = !entry.triggers.isEmpty

        // Debug: this only appears when a trigger-relevant symptom exists and entry.triggers is empty.
        guard shouldPrompt, !hasTriggers else { return [] }

        let sessionName = sessionNameText(for: entry)
        let title = notificationTitle(for: entry)

        // Debug: use this to confirm the app is encouraging the caregiver to log possible triggers.
        return [
            NotificationPlan(
                id: "entry-\(String(describing: entry.id))-triggers",
                title: title,
                body: "Would you like to record possible triggers for \(sessionName), such as food, movement, heat, light, or missed sleep?",
                timeInterval: debugInterval("debugTriggerLoggingInterval", fallback: 7)
            )
        ]
    }

    static func patternObservations(for entry: PainEntry, recentEntries: [PainEntry]) -> [NotificationPlan] {
        // Pattern observation notification:
        // Triggered when the current entry shares symptoms with at least two recent entries.
        guard !entry.symptoms.isEmpty else { return [] }

        let currentSymptoms = Set(entry.symptoms.map { $0.lowercased() })

        // Count how many recent entries overlap with the current entry's symptoms.
        let repeatedCount = recentEntries.filter { oldEntry in
            let oldSymptoms = Set(oldEntry.symptoms.map { $0.lowercased() })
            return !currentSymptoms.isDisjoint(with: oldSymptoms)
        }.count

        // Debug: this will only appear once there is enough recent matching history.
        guard repeatedCount >= 2 else { return [] }

        let sessionName = sessionNameText(for: entry)
        let title = notificationTitle(for: entry)

        // Debug: useful for confirming history-based notifications are being generated.
        return [
            NotificationPlan(
                id: "entry-\(String(describing: entry.id))-pattern",
                title: title,
                body: "A similar symptom has been logged multiple times recently for \(sessionName). Consider reviewing whether it is improving.",
                timeInterval: debugInterval("debugPatternObservationInterval", fallback: 8)
            )
        ]
    }

    static func missingInformationReminders(for entry: PainEntry) -> [NotificationPlan] {
        // Missing-information reminder notifications:
        // These prompt the caregiver to add helpful missing context after saving an entry.
        var plans: [NotificationPlan] = []

        let sessionName = sessionNameText(for: entry)
        let title = notificationTitle(for: entry)

        // Headache with no location logged.
        // Debug: should fire when headache exists but no body location has been selected.
        if entry.symptoms.contains(where: { $0.lowercased() == "headache" }) && entry.locations.isEmpty {
            plans.append(
                NotificationPlan(
                    id: "entry-\(String(describing: entry.id))-missing-location",
                    title: title,
                    body: "You logged a headache for \(sessionName). Consider adding the pain location.",
                    timeInterval: debugInterval("debugMissingLocationInterval", fallback: 9)
                )
            )
        }

        // Medicine logged but no next reminder time set.
        // Debug: should fire when medicineTaken is true and reminder date is nil.
        if entry.medicineTaken && entry.nextMedicationReminderDate == nil {
            plans.append(
                NotificationPlan(
                    id: "entry-\(String(describing: entry.id))-missing-med-reminder",
                    title: title,
                    body: "You logged medicine for \(sessionName) but did not set a next reminder time.",
                    timeInterval: debugInterval("debugMissingMedicationReminderInterval", fallback: 10)
                )
            )
        }

        // No relievers were recorded for this entry.
        // Debug: should fire whenever entry.relievers is empty.
        if entry.relievers.isEmpty {
            plans.append(
                NotificationPlan(
                    id: "entry-\(String(describing: entry.id))-missing-reliever",
                    title: title,
                    body: "Recording what helped or did not help for \(sessionName) can improve later summaries.",
                    timeInterval: debugInterval("debugMissingRelieverInterval", fallback: 11)
                )
            )
        }

        return plans
    }
}
