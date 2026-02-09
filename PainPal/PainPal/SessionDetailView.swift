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
    var session: Session
    // Reactive SwiftData query for this session's non-deleted entries.
    // Using @Query makes the list update immediately when `isDeleted` changes.
    @Query private var entries: [PainEntry]

    // Controls presentation of the RecordEntryView sheet.
    @State private var showingRecord = false
    // Controls presentation of the edit sheet for an existing entry.
    @State private var editingEntry: PainEntry? = nil

    // Analysis (prepare prompt input)
    @State private var analysisCount: Int = 15   // user can choose 10–20
    @State private var showingAnalysis = false
    @State private var preparedCaregiverNote: String = ""

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

    private func groupEntriesByDay(_ entries: [PainEntry]) -> [(day: Date, entries: [PainEntry])] {
        if entries.isEmpty { return [] }
        let grouped = Dictionary(grouping: entries) { e in
            Calendar.current.startOfDay(for: e.timestamp)
        }
        let sortedDays = grouped.keys.sorted(by: >)
        let result: [(Date, [PainEntry])] = sortedDays.map { day in
            let dayEntries = (grouped[day] ?? []).sorted { $0.timestamp > $1.timestamp }
            return (day, dayEntries)
        }
        return result
    }

    private var computedAgeString: String? {
        guard let dob = session.dateOfBirth else { return nil }
        return Session.ageString(for: dob)
    }

    var body: some View {
        List {
            if entries.isEmpty {
                Text("No entries yet. Tap Record to add one.")
                    .foregroundStyle(.secondary)
            } else {
                let dayGroups = groupEntriesByDay(entries)
                ForEach(dayGroups, id: \.day) { dayGroup in
                    Section {
                        ForEach(dayGroup.entries) { e in
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
                            for i in idx {
                                dayGroup.entries[i].softDelete()
                            }
                            try? ctx.save()
                        }
                    } header: {
                        Text(dayGroup.day.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
        }
        .navigationTitle(session.childName)
        .headerProminence(.increased)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Record") { showingRecord = true }

                Menu {
                    Stepper("Use last \(analysisCount) records", value: $analysisCount, in: 10...20)

                    Button {
                        preparedCaregiverNote = buildCaregiverNote(session: session, entries: entries, lastN: analysisCount)
                        showingAnalysis = true
                    } label: {
                        Label("Prepare caregiver note", systemImage: "sparkles")
                    }

#if DEBUG
                    Divider()
                    Button {
                        seedDemoEthanWongIfNeeded()
                    } label: {
                        Label("Insert demo child (Ethan Wong)", systemImage: "tray.and.arrow.down")
                    }
#endif
                } label: {
                    Image(systemName: "wand.and.stars")
                }
                .accessibilityLabel("Analyse")
            }
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
        .sheet(isPresented: $showingAnalysis) {
            NavigationStack {
                PreparedNoteView(
                    childName: session.childName,
                    ageDisplay: computedAgeString,
                    lastN: analysisCount,
                    note: preparedCaregiverNote
                )
            }
        }
    }
}

private extension SessionDetailView {
    func buildCaregiverNote(session: Session, entries: [PainEntry], lastN: Int) -> String {
        let recent = entries
            .filter { !$0.isDeleted }
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(lastN)

        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "yyyy-MM-dd HH:mm"

        func joinOr(_ arr: [String], empty fallback: String) -> String {
            arr.isEmpty ? fallback : arr.joined(separator: ", ")
        }

        func clipped(_ s: String, limit: Int = 180) -> String {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? "" : String(t.prefix(limit))
        }

        let scores = recent.map(\.score)
        let scoreLine: String = {
            guard let latest = scores.first else { return "No recorded entries yet." }
            let minS = scores.min() ?? latest
            let maxS = scores.max() ?? latest
            return "Recent scores (latest→older): \(scores.map(String.init).joined(separator: " → ")). Range: \(minS)–\(maxS)/10."
        }()

        var lines: [String] = []
        let ageSuffix = computedAgeString.map { ", \($0)" } ?? ""
        lines.append("Child: \(session.childName)\(ageSuffix).")
        lines.append(scoreLine)
        lines.append("Records:")

        for e in recent {
            let when = df.string(from: e.timestamp)
            let notesShort = clipped(e.notes)

            lines.append("""
            - \(when): score \(e.score)/10 (\(e.scale.rawValue)); trend: \(e.trend); duration: \(e.durationMinutes) min;
              locations: \(joinOr(e.locations, empty: "unknown"));
              quality: \(joinOr(e.qualityWords, empty: "unknown"));
              symptoms: \(joinOr(e.symptoms, empty: "none reported"));
              triggers: \(joinOr(e.triggers, empty: "unknown"));
              relievers: \(joinOr(e.relievers, empty: "unknown"));
              notes: \(notesShort.isEmpty ? "none" : notesShort).
            """)
        }

        return lines.joined(separator: "\n")
    }
}

private struct PreparedNoteView: View {
    @Environment(\.dismiss) private var dismiss
    private let ai = PainPalAIClient()
    @State private var isRunningTrend = false
    @State private var isRunningTriage = false
    @State private var trendResult: TrendSummary?
    @State private var triageResult: PainPalAssessment?
    @State private var errorText: String?

    let childName: String
    let ageDisplay: String?
    let lastN: Int
    let note: String

    var body: some View {
        Form {
            Section("Preview") {
                VStack(alignment: .leading, spacing: 6) {
                    Text(childName)
                        .font(.headline)
                    if let ageDisplay {
                        Text(ageDisplay)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Using last \(lastN) record\(lastN == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Caregiver note to feed the model") {
                Text(note)
                    .font(.footnote)
                    .textSelection(.enabled)
            }

            Section {
                ShareLink(item: note) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            
            Section("AI") {
                Button(isRunningTrend ? "Summarising..." : "Summarise trend") {
                    Task {
                        errorText = nil
                        isRunningTrend = true
                        defer { isRunningTrend = false }
                        do {
                            trendResult = try await ai.summariseTrend(from: note)
                        } catch {
                            errorText = String(describing: error)
                        }
                    }
                }
                .disabled(isRunningTrend || note.isEmpty)

                Button(isRunningTriage ? "Analysing..." : "Assess red flags / next steps") {
                    Task {
                        errorText = nil
                        isRunningTriage = true
                        defer { isRunningTriage = false }
                        do {
                            // If trend exists, include it as context; otherwise assess directly from the note.
                            if let t = trendResult {
                                triageResult = try await ai.assess(from: note, trend: t)
                            } else {
                                triageResult = try await ai.assess(from: note)
                            }
                        } catch {
                            errorText = String(describing: error)
                        }
                    }
                }
                .disabled(isRunningTriage || note.isEmpty)

                if let err = errorText {
                    Text(err).foregroundStyle(.red)
                }
            }
            if let t = trendResult {
                Section("TrendSummary") {
                    Text("Trend: \(t.trend)")
                        .font(.headline)

                    if !t.scoreSeriesLatestToOldest.isEmpty {
                        Text("Scores: " + t.scoreSeriesLatestToOldest.map(String.init).joined(separator: " → "))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Text(t.oneParagraphSummary)

                    if !t.redFlags.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Red flags:")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            ForEach(Array(t.redFlags.enumerated()), id: \.offset) { _, flag in
                                Text("• \(flag)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    if !t.questionsToAskNext.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Questions:")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            ForEach(Array(t.questionsToAskNext.enumerated()), id: \.offset) { _, q in
                                Text("• \(q)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }

            if let a = triageResult {
                Section("PainPalAssessment") {
                    Text("Danger level: \(a.dangerLevel)")
                        .font(.headline)
                    Text(a.whyThisLevel)
                    Text(a.recommendedNextStep)

                    if !a.questionsToAskNext.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Questions:")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            ForEach(Array(a.questionsToAskNext.enumerated()), id: \.offset) { _, q in
                                Text("• \(q)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    if !a.redFlagsDetected.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Red flags:")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            ForEach(Array(a.redFlagsDetected.enumerated()), id: \.offset) { _, flag in
                                Text("• \(flag)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Prepared Note")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview("SessionDetailView") {
    // In-memory SwiftData container for previews (does not persist between runs).
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, PainEntry.self, configurations: config)
    let ctx = container.mainContext

    // Demo child + 10 records to stress-test trend summarisation + red-flag detection.
    let calendar = Calendar.current
    let dob = calendar.date(byAdding: .month, value: -(2 * 12 + 8), to: Date())! // ~2y 8m ago

    let s = Session(childName: "Ethan Wong", dateOfBirth: dob)

    func d(_ daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
        let base = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base)!
    }

    let demoEntries: [PainEntry] = [
        PainEntry(
            scale: .wongBaker,
            score: 2,
            notes: "Mild tummy discomfort after dinner; settled quickly.",
            timestamp: d(30, 19, 20),
            trend: "Same",
            durationMinutes: 10,
            locations: ["Lower abdomen"],
            qualityWords: ["Aching"],
            symptoms: [],
            triggers: ["Eating"],
            relievers: ["Rest"],
            session: s
        ),
        PainEntry(
            scale: .wongBaker,
            score: 3,
            notes: "Complained of tummy pain in the evening; a bit clingy.",
            timestamp: d(27, 20, 10),
            trend: "Worse",
            durationMinutes: 15,
            locations: ["Lower right abdomen"],
            qualityWords: ["Cramping"],
            symptoms: ["Reduced appetite"],
            triggers: ["Evening"],
            relievers: ["Cuddle", "Rest"],
            session: s
        ),
        PainEntry(
            scale: .rFLACC,
            score: 4,
            notes: "Points to belly button area; curls up briefly; then plays again.",
            timestamp: d(24, 18, 45),
            trend: "Worse",
            durationMinutes: 20,
            locations: ["Belly button area"],
            qualityWords: ["Cramping"],
            symptoms: ["Irritable"],
            triggers: ["After eating"],
            relievers: ["Rest"],
            session: s
        ),
        PainEntry(
            scale: .rFLACC,
            score: 4,
            notes: "Pain mainly evenings; walked normally; no vomiting.",
            timestamp: d(21, 19, 30),
            trend: "Same",
            durationMinutes: 25,
            locations: ["Lower right abdomen"],
            qualityWords: ["Aching"],
            symptoms: [],
            triggers: ["Evening"],
            relievers: ["Warm compress"],
            session: s
        ),
        PainEntry(
            scale: .wongBaker,
            score: 5,
            notes: "Woke at night crying; guarding belly; settled after paracetamol.",
            timestamp: d(14, 1, 15),
            trend: "Worse",
            durationMinutes: 40,
            locations: ["Lower right abdomen"],
            qualityWords: ["Sharp"],
            symptoms: ["Sleep disrupted"],
            triggers: ["Night"],
            relievers: ["Paracetamol", "Rest"],
            session: s
        ),
        PainEntry(
            scale: .wongBaker,
            score: 5,
            notes: "More frequent episodes this week; refused some food.",
            timestamp: d(10, 18, 55),
            trend: "Worse",
            durationMinutes: 35,
            locations: ["Lower abdomen"],
            qualityWords: ["Cramping"],
            symptoms: ["Reduced appetite"],
            triggers: ["After eating"],
            relievers: ["Rest"],
            session: s
        ),
        PainEntry(
            scale: .rFLACC,
            score: 6,
            notes: "Crying more; says tummy hurts; looks pale.",
            timestamp: d(6, 19, 40),
            trend: "Worse",
            durationMinutes: 50,
            locations: ["Lower right abdomen"],
            qualityWords: ["Sharp"],
            symptoms: ["Pale"],
            triggers: ["Movement"],
            relievers: ["Rest"],
            session: s
        ),
        PainEntry(
            scale: .rFLACC,
            score: 6,
            notes: "Walks slower; guarding belly when picked up.",
            timestamp: d(3, 18, 20),
            trend: "Same",
            durationMinutes: 60,
            locations: ["Lower right abdomen", "Belly button area"],
            qualityWords: ["Sharp"],
            symptoms: ["Guarding"],
            triggers: ["Movement"],
            relievers: ["Rest"],
            session: s
        ),
        PainEntry(
            scale: .wongBaker,
            score: 7,
            notes: "Vomited once; feels hot; refusing fluids.",
            timestamp: d(1, 20, 05),
            trend: "Worse",
            durationMinutes: 120,
            locations: ["Lower right abdomen"],
            qualityWords: ["Sharp"],
            symptoms: ["Vomiting", "Fever", "Refusing fluids"],
            triggers: ["Unknown"],
            relievers: ["Rest"],
            session: s
        ),
        PainEntry(
            scale: .wongBaker,
            score: 8,
            notes: "Sudden severe pain started ~3 hours ago; won't walk; guarding belly; vomited twice; temp 38.9°C; fewer wet nappies.",
            timestamp: d(0, 10, 10),
            trend: "Worse",
            durationMinutes: 180,
            locations: ["Lower right abdomen", "Belly button area"],
            qualityWords: ["Severe", "Sharp"],
            symptoms: ["Vomiting", "Fever", "Won't walk", "Guarding", "Reduced urine"],
            triggers: ["Unknown"],
            relievers: ["None"],
            session: s
        )
    ]

    // Insert preview models into the in-memory context.
    ctx.insert(s)
    for e in demoEntries {
        ctx.insert(e)
    }

    return NavigationStack {
        SessionDetailView(session: s)
    }
    .modelContainer(container)
}

// Debug/demo seeding function for Ethan Wong test session
#if DEBUG
extension SessionDetailView {
    private func seedDemoEthanWongIfNeeded() {
        do {
            // Avoid duplicates: if a demo session already exists, do nothing.
            let existing = try ctx.fetch(FetchDescriptor<Session>(
                predicate: #Predicate { $0.childName == "Ethan Wong" }
            ))
            if !existing.isEmpty { return }

            let calendar = Calendar.current
            let dob = calendar.date(byAdding: .month, value: -(2 * 12 + 8), to: Date())! // ~2y 8m ago
            let s = Session(childName: "Ethan Wong", dateOfBirth: dob)

            func d(_ daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
                let base = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
                return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base)!
            }

            let demoEntries: [PainEntry] = [
                PainEntry(
                    scale: .wongBaker,
                    score: 2,
                    notes: "Mild tummy discomfort after dinner; settled quickly.",
                    timestamp: d(30, 19, 20),
                    trend: "Same",
                    durationMinutes: 10,
                    locations: ["Lower abdomen"],
                    qualityWords: ["Aching"],
                    symptoms: [],
                    triggers: ["Eating"],
                    relievers: ["Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .wongBaker,
                    score: 3,
                    notes: "Complained of tummy pain in the evening; a bit clingy.",
                    timestamp: d(27, 20, 10),
                    trend: "Worse",
                    durationMinutes: 15,
                    locations: ["Lower right abdomen"],
                    qualityWords: ["Cramping"],
                    symptoms: ["Reduced appetite"],
                    triggers: ["Evening"],
                    relievers: ["Cuddle", "Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .rFLACC,
                    score: 4,
                    notes: "Points to belly button area; curls up briefly; then plays again.",
                    timestamp: d(24, 18, 45),
                    trend: "Worse",
                    durationMinutes: 20,
                    locations: ["Belly button area"],
                    qualityWords: ["Cramping"],
                    symptoms: ["Irritable"],
                    triggers: ["After eating"],
                    relievers: ["Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .rFLACC,
                    score: 4,
                    notes: "Pain mainly evenings; walked normally; no vomiting.",
                    timestamp: d(21, 19, 30),
                    trend: "Same",
                    durationMinutes: 25,
                    locations: ["Lower right abdomen"],
                    qualityWords: ["Aching"],
                    symptoms: [],
                    triggers: ["Evening"],
                    relievers: ["Warm compress"],
                    session: s
                ),
                PainEntry(
                    scale: .wongBaker,
                    score: 5,
                    notes: "Woke at night crying; guarding belly; settled after paracetamol.",
                    timestamp: d(14, 1, 15),
                    trend: "Worse",
                    durationMinutes: 40,
                    locations: ["Lower right abdomen"],
                    qualityWords: ["Sharp"],
                    symptoms: ["Sleep disrupted"],
                    triggers: ["Night"],
                    relievers: ["Paracetamol", "Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .wongBaker,
                    score: 5,
                    notes: "More frequent episodes this week; refused some food.",
                    timestamp: d(10, 18, 55),
                    trend: "Worse",
                    durationMinutes: 35,
                    locations: ["Lower abdomen"],
                    qualityWords: ["Cramping"],
                    symptoms: ["Reduced appetite"],
                    triggers: ["After eating"],
                    relievers: ["Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .rFLACC,
                    score: 6,
                    notes: "Crying more; says tummy hurts; looks pale.",
                    timestamp: d(6, 19, 40),
                    trend: "Worse",
                    durationMinutes: 50,
                    locations: ["Lower right abdomen"],
                    qualityWords: ["Sharp"],
                    symptoms: ["Pale"],
                    triggers: ["Movement"],
                    relievers: ["Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .rFLACC,
                    score: 6,
                    notes: "Walks slower; guarding belly when picked up.",
                    timestamp: d(3, 18, 20),
                    trend: "Same",
                    durationMinutes: 60,
                    locations: ["Lower right abdomen", "Belly button area"],
                    qualityWords: ["Sharp"],
                    symptoms: ["Guarding"],
                    triggers: ["Movement"],
                    relievers: ["Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .wongBaker,
                    score: 7,
                    notes: "Vomited once; feels hot; refusing fluids.",
                    timestamp: d(1, 20, 5),
                    trend: "Worse",
                    durationMinutes: 120,
                    locations: ["Lower right abdomen"],
                    qualityWords: ["Sharp"],
                    symptoms: ["Vomiting", "Fever", "Refusing fluids"],
                    triggers: ["Unknown"],
                    relievers: ["Rest"],
                    session: s
                ),
                PainEntry(
                    scale: .wongBaker,
                    score: 8,
                    notes: "Sudden severe pain started ~3 hours ago; won't walk; guarding belly; vomited twice; temp 38.9°C; fewer wet nappies.",
                    timestamp: d(0, 10, 10),
                    trend: "Worse",
                    durationMinutes: 180,
                    locations: ["Lower right abdomen", "Belly button area"],
                    qualityWords: ["Severe", "Sharp"],
                    symptoms: ["Vomiting", "Fever", "Won't walk", "Guarding", "Reduced urine"],
                    triggers: ["Unknown"],
                    relievers: ["None"],
                    session: s
                )
            ]

            ctx.insert(s)
            for e in demoEntries { ctx.insert(e) }
            try ctx.save()
        } catch {
            // Silent fail in debug seed.
        }
    }
}
#endif
