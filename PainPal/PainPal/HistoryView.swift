//
//  HistoryView.swift
//  PainPal
//
//  Created by Chapman Leung on 3/1/2026.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    // Recently Deleted screen.
    //
    // This view is the "trash bin" for both:
    //  - soft-deleted Sessions (child sessions)
    //  - soft-deleted PainEntry records (individual records within a session)
    //
    // We soft delete by toggling `isDeleted` and setting `deletedAt`, so items can be restored.
    // Permanent deletion is done only from this screen using `modelContext.delete(...)`.

    // SwiftData context used to persist restores / permanent deletes.
    @Environment(\.modelContext) private var ctx

    @State private var showingDeleteSessionConfirmation = false
    @State private var showingDeleteEntryConfirmation = false
    @State private var pendingSessionDeletion: Session?
    @State private var pendingEntryDeletion: PainEntry?

    // Fetch sessions that have been soft-deleted. Most recently deleted appears first.
    @Query(
        filter: #Predicate<Session> { $0.isDeleted },
        sort: [SortDescriptor(\Session.deletedAt, order: .reverse)]
    )
    private var deletedSessions: [Session]

    // Fetch records (PainEntry) that have been soft-deleted. Most recently deleted appears first.
    @Query(
        filter: #Predicate<PainEntry> { $0.isDeleted },
        sort: [SortDescriptor(\PainEntry.deletedAt, order: .reverse)]
    )
    private var deletedEntries: [PainEntry]

    var body: some View {
        Group {
            if deletedSessions.isEmpty && deletedEntries.isEmpty {
                ContentUnavailableView(
                    "Nothing in Recently Deleted",
                    systemImage: "trash",
                    description: Text("Deleted sessions and deleted records will appear here.")
                )
            } else {
                List {
                    if !deletedSessions.isEmpty {
                        Section("Deleted Sessions") {
                            ForEach(deletedSessions) { session in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.childName)
                                        .font(.headline)
                                    Text("Session")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Deleted \(session.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown date")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        session.restore()
                                        try? ctx.save()
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        pendingSessionDeletion = session
                                        showingDeleteSessionConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    if !deletedEntries.isEmpty {
                        Section("Deleted Records") {
                            ForEach(deletedEntries) { entry in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Deleted Record")
                                        .font(.headline)
                                    Text("Record entry • \(entry.timestamp.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Deleted \(entry.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown date")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        entry.restore()
                                        try? ctx.save()
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        pendingEntryDeletion = entry
                                        showingDeleteEntryConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Recently Deleted")
        .alert("Permanently delete session?", isPresented: $showingDeleteSessionConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingSessionDeletion = nil
            }
            Button("Delete", role: .destructive) {
                if let session = pendingSessionDeletion {
                    ctx.delete(session)
                    try? ctx.save()
                }
                pendingSessionDeletion = nil
            }
        } message: {
            Text("This session will be permanently deleted and cannot be restored.")
        }
        .alert("Permanently delete record?", isPresented: $showingDeleteEntryConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingEntryDeletion = nil
            }
            Button("Delete", role: .destructive) {
                if let entry = pendingEntryDeletion {
                    ctx.delete(entry)
                    try? ctx.save()
                }
                pendingEntryDeletion = nil
            }
        } message: {
            Text("This record will be permanently deleted and cannot be restored.")
        }
    }
}

#Preview {
    HistoryView()
}
