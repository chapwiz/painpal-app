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

    @Query private var allSessions: [Session]
    @Query private var allEntries: [PainEntry]
    @Query(filter: #Predicate<Session> { $0.isDeleted }) private var deletedSessions: [Session]
    @Query(filter: #Predicate<PainEntry> { $0.isDeleted }) private var deletedEntries: [PainEntry]

    var body: some View {
        Form {
            Section("General") {
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
            
            // Delete this before going live, just for testing
            Section("Demo Data") {
                let total = allSessions.count
                let active = allSessions.filter { !$0.isDeleted }.count
                let deleted = total - active

                Text("Sessions: \(total) (Active: \(active), Deleted: \(deleted))")
                Text("Entries: \(allEntries.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Insert demo sessions") {
                    DemoDataSeeder.seed(ctx: ctx, sessionCount: 24)
                    didSeedExampleData = true
                }

                Button("Clear all data", role: .destructive) {
                    // Delete sessions first (cascade should delete entries)
                    for s in allSessions { ctx.delete(s) }
                    // Delete any orphan entries (safety)
                    for e in allEntries { ctx.delete(e) }
                    didSeedExampleData = false
                }
            }

            Section("About") {
                Text("PainPal – prototype")
                Text("AI-Powered Pain Description Tool")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
