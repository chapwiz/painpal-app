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

    // Polymorphism with enum
    // We want to show deleted Sessions and deleted PainEntries in one unified list.
    // Swift doesn't allow storing different types in the same array without a wrapper,
    // so we use an enum to "type erase" them into a single `DeletedItem`.
    private enum DeletedItem: Identifiable {
        case entry(PainEntry)
        case session(Session)

        // Stable identifier for SwiftUI's diffing (prefix avoids collisions between types).
        var id: String {
            switch self {
            case .entry(let e):
                return "entry-\(e.persistentModelID)"
            case .session(let s):
                return "session-\(s.persistentModelID)"
            }
        }

        // When the item was soft-deleted (used for sorting and display).
        var deletedAt: Date {
            switch self {
            case .entry(let e):
                return e.deletedAt ?? .distantPast
            case .session(let s):
                return s.deletedAt ?? .distantPast
            }
        }

        // Primary title shown in the list row.
        var title: String {
            switch self {
            case .entry(let e):
                return e.session?.childName ?? "Unknown Session"
            case .session(let s):
                return s.childName
            }
        }

        // Secondary text shown under the title.
        var subtitle: String {
            switch self {
            case .entry(let e):
                return "Record • \(e.timestamp.formatted(date: .abbreviated, time: .shortened))"
            case .session:
                return "Session"
            }
        }

        // Human-readable "Deleted ..." string.
        var deletedAtText: String {
            "Deleted \(deletedAt.formatted(date: .abbreviated, time: .shortened))"
        }
    }

    // Merge deleted entries + sessions into a single array and sort by deletion time.
    private var deletedItems: [DeletedItem] {
        let items: [DeletedItem] =
            deletedEntries.map { .entry($0) } +
            deletedSessions.map { .session($0) }
        return items.sorted { $0.deletedAt > $1.deletedAt }
    }

    var body: some View {
        Group {
            // Empty state when nothing has been soft-deleted yet.
            if deletedItems.isEmpty {
                ContentUnavailableView(
                    "Nothing in Recently Deleted",
                    systemImage: "trash",
                    description: Text("Deleted sessions and deleted records will appear here.")
                )
            } else {
                // Unified list of deleted items (records + sessions).
                List {
                    ForEach(deletedItems) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.deletedAtText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                // Restore = undo soft delete (keeps the object in the database).
                                switch item {
                                case .entry(let e):
                                    e.restore()
                                case .session(let s):
                                    s.restore()
                                }
                                try? ctx.save()
                            } label: {
                                Label("Restore", systemImage: "arrow.uturn.backward")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                // Delete = permanent delete from SwiftData store.
                                switch item {
                                case .entry(let e):
                                    ctx.delete(e)
                                case .session(let s):
                                    ctx.delete(s)
                                }
                                try? ctx.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Recently Deleted")
    }
}
