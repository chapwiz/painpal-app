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

                            // Quick facts
                            HStack(spacing: 10) {
                                if e.durationMinutes > 0 {
                                    let h = e.durationMinutes / 60
                                    let m = e.durationMinutes % 60
                                    if h > 0 {
                                        Text(m > 0 ? "Duration: \(h)h \(m)m" : "Duration: \(h)h")
                                    } else {
                                        Text("Duration: \(m)m")
                                    }
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            // Structured lists
                            if !e.locations.isEmpty {
                                Text("Areas: \(e.locations.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !e.qualityWords.isEmpty {
                                Text("Quality: \(e.qualityWords.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !e.symptoms.isEmpty {
                                Text("Symptoms: \(e.symptoms.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !e.triggers.isEmpty {
                                Text("Triggers: \(e.triggers.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !e.relievers.isEmpty {
                                Text("Relievers: \(e.relievers.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !e.notes.isEmpty {
                                Text(e.notes)
                            }

                            if let t = e.transcript, !t.isEmpty {
                                Text("Transcript: \(t)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
    let e1 = PainEntry(
        scale: .wongBaker,
        score: 6,
        notes: "Crying after meal",
        transcript: "He says his tummy hurts",
        aiSummary: "Pain after eating; possible stomach discomfort.",
        trend: "Worse",
        durationMinutes: 35,
        locations: ["Abdomen"],
        qualityWords: ["Cramping"],
        symptoms: ["Nausea"],
        triggers: ["Eating"],
        relievers: ["Rest"],
        session: s
    )

    let e2 = PainEntry(
        scale: .rFLACC,
        score: 4,
        notes: "Settled after rest",
        aiSummary: "Improved after rest; monitor.",
        trend: "Better",
        durationMinutes: 0,
        locations: ["Head"],
        qualityWords: ["Aching"],
        symptoms: [],
        triggers: ["Movement"],
        relievers: ["Rest", "Hydration"],
        session: s
    )

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

