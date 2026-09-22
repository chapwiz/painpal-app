//
//  SessionDetailView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData

// Displays a single child session and its pain records (timeline).
//
// Key idea: we soft-delete PainEntry records by toggling `isDeleted` so they can be restored
// from the "Recently Deleted" screen. This view only queries and shows active (non-deleted) entries.

struct SessionDetailView: View {
    // SwiftData context used to persist soft-deletes.
    @Environment(\.modelContext) private var ctx
    // The parent session being displayed.
    @Bindable var session: Session
    // Reactive SwiftData query for this session's non-deleted entries.
    // Using @Query makes the list update immediately when `isDeleted` changes.
    @Query private var entries: [PainEntry]

    // Controls presentation of the RecordEntryView sheet.
    @State private var showingRecord = false
    // Controls presentation of the edit sheet for an existing entry.
    @State private var editingEntry: PainEntry? = nil

    init(session: Session) {
        self.session = session
        // Capture the session's persistent identifier for use inside the SwiftData predicate.
        // Predicates are expression-based, so comparing by persistentModelID is safer than
        // capturing the Session model object directly.
        let sid = session.persistentModelID
        // Fetch only entries that belong to this session AND are not soft-deleted.
        _entries = Query(
            filter: #Predicate<PainEntry> { $0.session?.persistentModelID == sid && !$0.isDeleted },
            sort: \PainEntry.timestamp,
            order: .reverse
        )
    }

    var body: some View {
        List {
            if entries.isEmpty {
                Text("No entries yet. Tap Record to add one.")
                    .foregroundStyle(.secondary)
            } else {
                // Group entries by day (local timezone) and show most-recent day first.
                let grouped = Dictionary(grouping: entries) { e in
                    Calendar.current.startOfDay(for: e.timestamp)
                }
                let days = grouped.keys.sorted(by: >)

                ForEach(days, id: \.self) { day in
                    // Sort entries within each day newest-to-oldest.
                    let dayEntries = (grouped[day] ?? []).sorted { $0.timestamp > $1.timestamp }

                    Section {
                        ForEach(dayEntries) { e in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("\(e.scale.rawValue) • \(e.score)/10")
                                        .font(.headline)

                                    Spacer()

                                    Button {
                                        editingEntry = e
                                    } label: {
                                        Image(systemName: "pencil")
                                    }
                                    .buttonStyle(.borderless)
                                    .foregroundStyle(.secondary)
                                    .accessibilityLabel("Edit entry")

                                    Text(e.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                // Quick facts
                                // Duration formatting (minutes -> h/m) for a compact display.
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

                                // Structured multi-select fields captured during recording.
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
                        // Soft-delete records so they appear in Recently Deleted (HistoryView).
                        .onDelete { idx in
                            for i in idx {
                                dayEntries[i].softDelete()
                            }
                            try? ctx.save()
                        }
                    } header: {
                        // Section header provides a clear date divider.
                        Text(day.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
        }
        .navigationTitle(session.childName)
        .headerProminence(.increased)
        .toolbar {
            // Opens the recording form to add a new PainEntry to this session.
            Button("Record") { showingRecord = true }
        }
        .sheet(isPresented: $showingRecord) {
            NavigationStack {
                // RecordEntryView writes a new PainEntry linked to this session.
                RecordEntryView(session: session)
            }
        }
        .sheet(item: $editingEntry) { entry in
            NavigationStack {
                RecordEntryView(session: session, editingEntry: entry)
            }
        }
    }
}

#Preview("SessionDetailView") {
    // In-memory SwiftData container for previews (does not persist between runs).
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, PainEntry.self, configurations: config)
    let ctx = container.mainContext

    // Sample session + two sample entries to demonstrate the UI.
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

    // Insert preview models into the in-memory context.
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
