//
//  SessionDetailView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var session: Session

    @State private var showingRecord = false

    private var entriesSorted: [PainEntry] {
        session.entries.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        List {
            Section("Timeline") {
                if entriesSorted.isEmpty {
                    Text("No entries yet. Tap Record to add one.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entriesSorted) { e in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(e.scale.rawValue) • \(e.score)/10")
                                    .font(.headline)
                                Spacer()
                                Text(e.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !e.notes.isEmpty {
                                Text(e.notes)
                            }

                            if let summary = e.aiSummary, !summary.isEmpty {
                                Text("Summary: \(summary)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { idx in
                        let toDelete = idx.map { entriesSorted[$0] }
                        for e in toDelete {
                            session.entries.removeAll { $0.id == e.id }
                            ctx.delete(e)
                        }
                    }
                }
            }
        }
        .navigationTitle(session.childName)
        .toolbar {
            Button("Record") { showingRecord = true }
        }
        .sheet(isPresented: $showingRecord) {
            NavigationStack {
                RecordEntryView(session: session)
            }
        }
    }
}

#Preview("SessionDetailView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, PainEntry.self, configurations: config)
    let ctx = container.mainContext

    let s = Session(childName: "Amy")
    let e1 = PainEntry(scale: .wongBaker, score: 6, notes: "Crying after meal", session: s)
    let e2 = PainEntry(scale: .rFLACC, score: 4, notes: "Settled after rest", session: s)

    let _ = {
        ctx.insert(s)
        ctx.insert(e1)
        ctx.insert(e2)
    }()

    return NavigationStack {
        SessionDetailView(session: s)
    }
    .modelContainer(container)
}
