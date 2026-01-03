//
//  HistoryView.swift
//  PainPal
//
//  Created by Chapman Leung on 3/1/2026.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var ctx

    @Query(
        filter: #Predicate<Session> { $0.isDeleted },
        sort: [SortDescriptor(\Session.deletedAt, order: .reverse)]
    )
    private var deletedSessions: [Session]

    var body: some View {
        Group {
            if deletedSessions.isEmpty {
                ContentUnavailableView(
                    "No recently deleted sessions",
                    systemImage: "trash",
                    description: Text("Swipe-delete a session from the Sessions tab and it will appear here.")
                )
            } else {
                List {
                    ForEach(deletedSessions) { s in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.childName)
                                .font(.headline)

                            if let d = s.deletedAt {
                                Text("Deleted \(d.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                s.restore()
                            } label: {
                                Label("Restore", systemImage: "arrow.uturn.backward")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                ctx.delete(s)
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
