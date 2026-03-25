//
//  SessionDetailView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData

private enum HistoryMode: String, CaseIterable, Identifiable {
    case detail = "Detail"
    case calendar = "Calendar"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .detail: return "list.bullet"
        case .calendar: return "calendar"
        }
    }
}


private enum AIFlowDestination: String, Identifiable {
    case caregiverNote
    case trendSummary
    case redFlagAssessment

    var id: String { rawValue }
}

private struct SelectedEntryTarget: Identifiable, Equatable {
    let id: PersistentIdentifier
}

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


    // Analysis (prepare prompt input)
    @State private var analysisCount: Int = 15   // user can choose 10–20
    @State private var activeAIDestination: AIFlowDestination?
    @State private var preparedCaregiverNote: String = ""
    @State private var showingAIPopover = false
    @State private var historyMode: HistoryMode = .calendar
    @State private var calendarMonth = Calendar.current.startOfMonth(for: Date())
    @State private var selectedCalendarDay: Date?
    @State private var calendarTransitionDirection: Int = 0
    @State private var calendarAnimationToken = UUID()
    @State private var selectedEntryForRecording: SelectedEntryTarget?

    
    // Keep the record destination stable so SwiftUI does not recreate it on every body update.
    private let recordEntryView: RecordEntryView

    init(session: Session) {
        self.session = session
        let sid = session.persistentModelID
        _entries = Query(
            filter: #Predicate<PainEntry> { $0.session?.persistentModelID == sid && !$0.isDeleted },
            sort: \PainEntry.timestamp,
            order: .reverse
        )
        self.recordEntryView = RecordEntryView(session: session)
    }

    var body: some View {
        Group {
            if historyMode == .detail {
                detailView
            } else {
                calendarView
            }
        }
        .navigationTitle(session.childName)
        .headerProminence(.increased)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(destination: recordEntryView) {
                    Image(systemName: "plus")
                }

                Button {
                    showingAIPopover = true
                } label: {
                    Image(systemName: "sparkles")
                }
                .accessibilityLabel("AI features")
                .popover(isPresented: $showingAIPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("AI summary generation from recent records")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Choose how many records to use.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("Using last \(analysisCount) records")
                                .font(.subheadline.weight(.medium))

                            Stepper(value: $analysisCount, in: 10...20) {
                                EmptyView()
                            }
                            .labelsHidden()
                        }

                        VStack(spacing: 8) {
                            Button {
                                preparedCaregiverNote = buildCaregiverNote(session: session, entries: entries, lastN: analysisCount)
                                showingAIPopover = false
                                DispatchQueue.main.async {
                                    activeAIDestination = .caregiverNote
                                }
                            } label: {
                                Text("Prepare caregiver note")
                                    .font(.footnote.weight(.semibold))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)

                            Button {
                                preparedCaregiverNote = buildCaregiverNote(session: session, entries: entries, lastN: analysisCount)
                                showingAIPopover = false
                                DispatchQueue.main.async {
                                    activeAIDestination = .trendSummary
                                }
                            } label: {
                                Text("Summarise trend")
                                    .font(.footnote.weight(.semibold))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Button {
                                preparedCaregiverNote = buildCaregiverNote(session: session, entries: entries, lastN: analysisCount)
                                showingAIPopover = false
                                DispatchQueue.main.async {
                                    activeAIDestination = .redFlagAssessment
                                }
                            } label: {
                                Text("Assess red flags / next steps")
                                    .font(.footnote.weight(.semibold))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .frame(width: 150)
                    }
                    .padding(18)
                    .frame(width: 420)
                    .presentationCompactAdaptation(.popover)
                }

                Menu {
                    Picker("History View", selection: $historyMode) {
                        ForEach(HistoryMode.allCases) { mode in
                            Label(mode.rawValue, systemImage: mode.iconName)
                                .tag(mode)
                        }
                    }

                    Divider()

#if DEBUG
                    Divider()
                    Button {
                        seedDemoEthanWongIfNeeded()
                    } label: {
                        Label("Insert demo child (Ethan Wong)", systemImage: "tray.and.arrow.down")
                    }
#endif
                } label: {
                    Image(systemName: historyMode.iconName)
                }
                .accessibilityLabel("View options")
            }
        }
        .sheet(item: $activeAIDestination) { destination in
            NavigationStack {
                switch destination {
                case .caregiverNote:
                    PreparedCaregiverNoteView(
                        childName: session.childName,
                        ageDisplay: computedAgeString,
                        lastN: analysisCount,
                        note: preparedCaregiverNote
                    )
                    .presentationDetents([.fraction(0.56), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(58)
                case .trendSummary:
                    TrendSummaryResultView(
                        childName: session.childName,
                        ageDisplay: computedAgeString,
                        lastN: analysisCount,
                        note: preparedCaregiverNote
                    )
                    .presentationDetents([.fraction(0.56), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(58)
                case .redFlagAssessment:
                    RedFlagAssessmentView(
                        childName: session.childName,
                        ageDisplay: computedAgeString,
                        lastN: analysisCount,
                        note: preparedCaregiverNote
                    )
                    .presentationDetents([.fraction(0.56), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(58)
                }
            }
        }
        .sheet(item: $selectedEntryForRecording) { target in
            NavigationStack {
                if let entry = entries.first(where: { $0.persistentModelID == target.id }) {
                    RecordEntryView(session: session, editingEntry: entry)
                } else {
                    ContentUnavailableView("Entry unavailable", systemImage: "exclamationmark.triangle")
                }
            }
        }
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

    private func displayText(for rawLocation: String) -> String {
        PainLocation.allCases.first(where: { $0.rawValue == rawLocation })?.displayName ?? rawLocation
    }

    private func delete(_ entry: PainEntry) {
        entry.softDelete()
        try? ctx.save()
    }

    private func shiftCalendarMonth(by offset: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: calendarMonth) else { return }
        calendarTransitionDirection = offset >= 0 ? 1 : -1
        withAnimation(.easeInOut(duration: 0.26)) {
            calendarMonth = Calendar.current.startOfMonth(for: newMonth)
            calendarAnimationToken = UUID()
        }
    }

    private func updateCalendarMonth(month: Int? = nil, year: Int? = nil) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: calendarMonth)
        if let month { components.month = month }
        if let year { components.year = year }
        guard let newDate = calendar.date(from: components) else { return }

        let newStart = calendar.startOfMonth(for: newDate)
        let currentComponents = calendar.dateComponents([.year, .month], from: calendarMonth)
        let newComponents = calendar.dateComponents([.year, .month], from: newStart)

        let currentIndex = (currentComponents.year ?? 0) * 12 + (currentComponents.month ?? 0)
        let newIndex = (newComponents.year ?? 0) * 12 + (newComponents.month ?? 0)
        calendarTransitionDirection = newIndex >= currentIndex ? 1 : -1

        withAnimation(.easeInOut(duration: 0.26)) {
            calendarMonth = newStart
            calendarAnimationToken = UUID()
        }
    }

    private var groupedEntriesByDay: [Date: [PainEntry]] {
        Dictionary(grouping: entries) { e in
            Calendar.current.startOfDay(for: e.timestamp)
        }
    }

    private var selectedDayEntries: [PainEntry] {
        guard let selectedCalendarDay else { return [] }
        let day = Calendar.current.startOfDay(for: selectedCalendarDay)
        return (groupedEntriesByDay[day] ?? []).sorted { $0.timestamp > $1.timestamp }
    }

    private var currentMonthTitle: String {
        calendarMonth.formatted(.dateTime.month(.wide).year())
    }

    private var monthDays: [Date?] {
        let calendar = Calendar.current
        let start = calendar.startOfMonth(for: calendarMonth)
        guard let dayRange = calendar.range(of: .day, in: .month, for: start) else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: start)
        let leadingEmpty = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in dayRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: start) {
                result.append(date)
            }
        }
        while result.count % 7 != 0 {
            result.append(nil)
        }
        return result
    }

    private func entries(for day: Date) -> [PainEntry] {
        let key = Calendar.current.startOfDay(for: day)
        return (groupedEntriesByDay[key] ?? []).sorted { $0.timestamp > $1.timestamp }
    }

    private func maxScore(for day: Date) -> Int? {
        entries(for: day).map(\.score).max()
    }

    private func tintOpacity(for day: Date) -> Double {
        guard let maxScore = maxScore(for: day) else { return 0 }
        return 0.14 + (Double(maxScore) / 10.0) * 0.36
    }

}

private extension SessionDetailView {
    func medicationDisplayLines(for entry: PainEntry) -> [String] {
        guard entry.medicineTaken else { return [] }

        var lines: [String] = []
        let trimmedName = entry.medicineName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInstructions = entry.medicationInstructions.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            lines.append("Medicine: taken")
        } else {
            lines.append("Medicine: \(trimmedName)")
        }

        if !trimmedInstructions.isEmpty {
            lines.append("Instructions: \(trimmedInstructions)")
        }

        if let reminderDate = entry.nextMedicationReminderDate {
            lines.append("Medication reminder: \(reminderDate.formatted(date: .abbreviated, time: .shortened))")
        }

        return lines
    }

    var detailView: some View {
        List {
            if entries.isEmpty {
                Text("No entries yet. Tap Record to add one.")
                    .foregroundStyle(.secondary)
            } else {
                let dayGroups = groupEntriesByDay(entries)
                ForEach(dayGroups, id: \.day) { dayGroup in
                    Section {
                        ForEach(dayGroup.entries) { e in
                            Button {
                                selectedEntryForRecording = SelectedEntryTarget(id: e.persistentModelID)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("\(e.scale.rawValue) • \(e.score)/10")
                                            .font(.headline)

                                        Spacer()

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
                                        Text("Areas: \(e.locations.map(displayText).joined(separator: ", "))")
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

                                    ForEach(medicationDisplayLines(for: e), id: \.self) { line in
                                        Text(line)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    if !e.notes.isEmpty {
                                        Text(e.notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    delete(e)
                                } label: {
                                    Image(systemName: "trash")
                                        .opacity(0.28)
                                }
                            }
                        }
                    } header: {
                        Text(dayGroup.day.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
        }
    }

    var calendarView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    VStack(spacing: 12) {
                        HStack {
                            Button {
                                if let previous = Calendar.current.date(byAdding: .month, value: -1, to: calendarMonth) {
                                    calendarMonth = Calendar.current.startOfMonth(for: previous)
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.green)
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Text(currentMonthTitle)
                                .font(.headline)

                            Spacer()

                            Button {
                                if let next = Calendar.current.date(byAdding: .month, value: 1, to: calendarMonth) {
                                    calendarMonth = Calendar.current.startOfMonth(for: next)
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.green)
                            }
                            .buttonStyle(.plain)
                        }

                        let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols
                        let orderedWeekdays = Array(weekdaySymbols.dropFirst(Calendar.current.firstWeekday - 1) + weekdaySymbols.prefix(Calendar.current.firstWeekday - 1))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                            ForEach(orderedWeekdays, id: \.self) { symbol in
                                Text(symbol)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                            }

                            ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                                if let date {
                                    let dayEntries = entries(for: date)
                                    let isSelected = selectedCalendarDay.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
                                    let maxScore = maxScore(for: date)

                                    Button {
                                        selectedCalendarDay = date
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text("\(Calendar.current.component(.day, from: date))")
                                                .font(.subheadline.weight(isSelected ? .bold : .regular))
                                                .foregroundStyle(Color.primary)

                                            if let maxScore {
                                                Text("\(maxScore)/10")
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.secondary)
                                            } else {
                                                Circle()
                                                    .fill(Color.clear)
                                                    .frame(width: 4, height: 4)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    isSelected
                                                    ? Color.green.opacity(0.38)
                                                    : (dayEntries.isEmpty ? Color.gray.opacity(0.08) : Color.green.opacity(0.18))
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Color.clear
                                        .frame(height: 60)
                                }
                            }
                        }
                    }
                    .id(calendarAnimationToken)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: calendarTransitionDirection >= 0 ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: calendarTransitionDirection >= 0 ? .leading : .trailing).combined(with: .opacity)
                        )
                    )
                }
                .frame(minHeight: 360)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .contentShape(RoundedRectangle(cornerRadius: 16))
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let horizontal = value.translation.width
                            let vertical = value.translation.height
                            guard abs(horizontal) > abs(vertical), abs(horizontal) > 30 else { return }
                            if horizontal < 0 {
                                shiftCalendarMonth(by: 1)
                            } else {
                                shiftCalendarMonth(by: -1)
                            }
                        }
                )

                Text("Days with entries show the highest pain score recorded that day.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let selectedCalendarDay {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(selectedCalendarDay.formatted(date: .complete, time: .omitted))
                            .font(.headline)

                        if selectedDayEntries.isEmpty {
                            Text("No entries for this day.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(selectedDayEntries) { e in
                                HStack(alignment: .top, spacing: 12) {
                                    Button {
                                        selectedEntryForRecording = SelectedEntryTarget(id: e.persistentModelID)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text("\(e.scale.rawValue) • \(e.score)/10")
                                                    .font(.headline)
                                                Spacer()
                                                Text(e.timestamp, style: .time)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }

                                            if !e.locations.isEmpty {
                                                Text("Areas: \(e.locations.map(displayText).joined(separator: ", "))")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }

                                            ForEach(medicationDisplayLines(for: e), id: \.self) { line in
                                                Text(line)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }

                                            if !e.notes.isEmpty {
                                                Text(e.notes)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)

                                    Button(role: .destructive) {
                                        delete(e)
                                    } label: {
                                        Image(systemName: "trash")
                                            .opacity(0.28)
                                    }
                                    .buttonStyle(.borderless)
                                    .accessibilityLabel("Delete entry")
                                }

                                if e.id != selectedDayEntries.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
            // animation removed to reduce jumpiness of footer and entries when swiping months
            .padding()
        }
        .onAppear {
            if selectedCalendarDay == nil {
                selectedCalendarDay = entries.first.map { Calendar.current.startOfDay(for: $0.timestamp) }
            }
        }
    }
}

private extension SessionDetailView {
    private func startOfMonth(for date: Date) -> Date {
        Calendar.current.startOfMonth(for: date)
    }

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

        func medicationSummary(for entry: PainEntry) -> String {
            guard entry.medicineTaken else { return "none recorded" }

            var parts: [String] = []

            let trimmedName = entry.medicineName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                parts.append("taken")
            } else {
                parts.append(trimmedName)
            }

            let trimmedInstructions = entry.medicationInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedInstructions.isEmpty {
                parts.append("instructions: \(trimmedInstructions)")
            }

            if let reminderDate = entry.nextMedicationReminderDate {
                parts.append("next reminder: \(df.string(from: reminderDate))")
            }

            return parts.joined(separator: "; ")
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
            let medicationLine = medicationSummary(for: e)

            lines.append("""
            - \(when): score \(e.score)/10 (\(e.scale.rawValue)); trend: \(e.trend); duration: \(e.durationMinutes) min;
              locations: \(joinOr(e.locations, empty: "unknown"));
              quality: \(joinOr(e.qualityWords, empty: "unknown"));
              symptoms: \(joinOr(e.symptoms, empty: "none reported"));
              triggers: \(joinOr(e.triggers, empty: "unknown"));
              relievers: \(joinOr(e.relievers, empty: "unknown"));
              medication: \(medicationLine);
              notes: \(notesShort.isEmpty ? "none" : notesShort).
            """)
        }

        return lines.joined(separator: "\n")
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

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
