//
//  SettingsView.swift
//  PainPal
//
//  Created by Chapman Leung on 3/1/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var ctx
    @AppStorage("didSeedExampleData") private var didSeedExampleData = false
    @AppStorage("userRole") private var userRoleRawValue = UserRole.caregiver.rawValue
    @State private var showingClearAllConfirmation = false
    @AppStorage("debugMedicineOutcomeInterval") private var debugMedicineOutcomeInterval: Double = 5
    @AppStorage("debugHydrationInterval") private var debugHydrationInterval: Double = 6
    @AppStorage("debugTriggerLoggingInterval") private var debugTriggerLoggingInterval: Double = 7
    @AppStorage("debugPatternObservationInterval") private var debugPatternObservationInterval: Double = 8
    @AppStorage("debugMissingLocationInterval") private var debugMissingLocationInterval: Double = 9
    @AppStorage("debugMissingMedicationReminderInterval") private var debugMissingMedicationReminderInterval: Double = 10
    @AppStorage("debugMissingRelieverInterval") private var debugMissingRelieverInterval: Double = 11

    private func applyDefaultNotificationIntervals() {
        debugMedicineOutcomeInterval = 45 * 60
        debugHydrationInterval = 60 * 60
        debugTriggerLoggingInterval = 45 * 60
        debugPatternObservationInterval = 60 * 60
        debugMissingLocationInterval = 45 * 60
        debugMissingMedicationReminderInterval = 60 * 60
        debugMissingRelieverInterval = 45 * 60
    }

    private func applyTestingNotificationIntervals() {
        debugMedicineOutcomeInterval = 5
        debugHydrationInterval = 6
        debugTriggerLoggingInterval = 7
        debugPatternObservationInterval = 8
        debugMissingLocationInterval = 9
        debugMissingMedicationReminderInterval = 10
        debugMissingRelieverInterval = 11
    }

    @Query private var allSessions: [Session]
    @Query private var allEntries: [PainEntry]
    @Query(filter: #Predicate<Session> { $0.isDeleted }) private var deletedSessions: [Session]
    @Query(filter: #Predicate<PainEntry> { $0.isDeleted }) private var deletedEntries: [PainEntry]

    var body: some View {
        Form {
            Section("General") {
                Picker("User role", selection: $userRoleRawValue) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.title).tag(role.rawValue)
                    }
                }
                Label("On-device only", systemImage: "lock")
                Text("No cloud sync in prototype.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Section("Recently Deleted") {
                let ds = deletedSessions.count
                let de = deletedEntries.count

                if ds == 0 && de == 0 {
                    Text("No recently deleted items")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Sessions: \(ds)")
                    Text("Entries: \(de)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                NavigationLink {
                    HistoryView()
                } label: {
                    Label("Manage Recently Deleted", systemImage: "trash")
                }
            }
            
            Section {
                Stepper(value: $debugMedicineOutcomeInterval, in: 1...300, step: 1) {
                    HStack {
                        Text("Medicine follow-up")
                        Spacer()
                        Text("\(Int(debugMedicineOutcomeInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(value: $debugHydrationInterval, in: 1...300, step: 1) {
                    HStack {
                        Text("Hydration prompt")
                        Spacer()
                        Text("\(Int(debugHydrationInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(value: $debugTriggerLoggingInterval, in: 1...300, step: 1) {
                    HStack {
                        Text("Trigger logging")
                        Spacer()
                        Text("\(Int(debugTriggerLoggingInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(value: $debugPatternObservationInterval, in: 1...300, step: 1) {
                    HStack {
                        Text("Pattern observation")
                        Spacer()
                        Text("\(Int(debugPatternObservationInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(value: $debugMissingLocationInterval, in: 1...300, step: 1) {
                    HStack {
                        Text("Missing location")
                        Spacer()
                        Text("\(Int(debugMissingLocationInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(value: $debugMissingMedicationReminderInterval, in: 1...300, step: 1) {
                    HStack {
                        Text("Missing med reminder")
                        Spacer()
                        Text("\(Int(debugMissingMedicationReminderInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(value: $debugMissingRelieverInterval, in: 1...300, step: 1) {
                    HStack {
                        Text("Missing reliever")
                        Spacer()
                        Text("\(Int(debugMissingRelieverInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Button("Apply default timings") {
                    applyDefaultNotificationIntervals()
                }

                Button("Apply testing timings") {
                    applyTestingNotificationIntervals()
                }
            } header: {
                Text("Developer / Demo Notification Timing")
            } footer: {
                Text("These values control the debug/demo notification delays in seconds. Use the default preset for realistic timings and the testing preset for quick demos.")
            }
            
            // Delete this before going live, just for testing
//            Section("Demo Data") {
//                let total = allSessions.count
//                let active = allSessions.filter { !$0.isDeleted }.count
//                let deleted = total - active
//
//                Text("Sessions: \(total) (Active: \(active), Deleted: \(deleted))")
//                Text("Entries: \(allEntries.count)")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//
//                Button("Insert demo sessions") {
//                    DemoDataSeeder.seed(ctx: ctx, sessionCount: 24)
//                    didSeedExampleData = true
//                }
//
//                Button("Clear all data", role: .destructive) {
//                    showingClearAllConfirmation = true
//                }
//            }

            Section("About") {
                Text("PainPal")
                Text("AI-Powered Pain Description Tool")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .alert("Delete all data?", isPresented: $showingClearAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Delete sessions first (cascade should delete entries)
                for s in allSessions { ctx.delete(s) }
                // Delete any orphan entries (safety)
                for e in allEntries { ctx.delete(e) }
                didSeedExampleData = false
            }
        } message: {
            Text("This will permanently delete all sessions and entries in the app. This action cannot be undone.")
        }
    }
}
