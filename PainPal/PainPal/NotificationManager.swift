//
//  NotificationManager.swift
//  PainPal
//
//  Created by Chapman Leung on 25/3/2026.
//

import Foundation
import UserNotifications

struct NotificationPlan: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let timeInterval: TimeInterval
}

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() async {
        do {
            let center = UNUserNotificationCenter.current()
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    func schedule(_ plan: NotificationPlan) {
        let content = UNMutableNotificationContent()
        content.title = plan.title
        content.body = plan.body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(plan.timeInterval, 1),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: plan.id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule notification \(plan.id): \(error)")
            }
        }
    }

    func scheduleAll(_ plans: [NotificationPlan]) {
        for plan in plans {
            schedule(plan)
        }
    }

    func scheduleMedicationReminder(
        entryID: UUID,
        childName: String,
        medicineName: String,
        instructions: String,
        reminderDate: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Medication reminder"
            : "Medication reminder: \(childName)"
        content.body = instructions.isEmpty
            ? "Time for \(medicineName)."
            : "Time for \(medicineName). Note: \(instructions)"
        content.sound = .default
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "entry-\(entryID.uuidString)-scheduled-medication",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule medication reminder: \(error)")
            }
        }
    }

    func removeNotifications(withPrefix prefix: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
