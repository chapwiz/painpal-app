//
//  ParentHomeView.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import SwiftUI
import SwiftData
import Charts

private enum ParentAIKind: String {
    case trendSummary
    case redFlagAssessment
}

private struct ParentAIRequest: Identifiable {
    let id = UUID()
    let kind: ParentAIKind
    let childName: String
    let ageDisplay: String?
    let lastN: Int
    let note: String
}

struct ParentHomeView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var allSessions: [Session]
    @Query private var allEntries: [PainEntry]
    @State private var selectedSessionID: PersistentIdentifier?
    @State private var showingNewSessionSheet = false
    @State private var showingQuickRecordSheet = false
    @State private var newChildName = ""
    @State private var hasDateOfBirth = false
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()

    @State private var showingAIPopover = false
    @State private var analysisCount = 5
    @State private var activeAIRequest: ParentAIRequest?
    @State private var cardSwipeOffset: CGFloat = 0
    @State private var showingDeleteChildConfirmation = false


    private var activeSessions: [Session] {
        allSessions
            .filter { !$0.isDeleted }
            .sorted { lhs, rhs in
                let lhsDate = latestEntryDate(for: lhs) ?? lhs.createdAt
                let rhsDate = latestEntryDate(for: rhs) ?? rhs.createdAt
                return lhsDate > rhsDate
            }
    }

    private var selectedSession: Session? {
        guard let selectedSessionID else { return nil }
        return activeSessions.first(where: { $0.persistentModelID == selectedSessionID })
    }

    private var recentEntries: [PainEntry] {
        guard let selectedSession else { return [] }
        return Array(fetchEntries(for: selectedSession).prefix(6))
    }

    private var latestEntry: PainEntry? {
        recentEntries.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let session = selectedSession {
                    swipeableHeaderCard(for: session)

                    insightCards(for: session)
                } else {
                    emptyStateCard
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom)
        }
        .overlay(alignment: .bottomTrailing) {
            if selectedSessionID != nil, selectedSession != nil {
                Button {
                    showingAIPopover = true
                } label: {
                    Image(systemName: "sparkles")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .accessibilityLabel("AI insights")
                .popover(isPresented: $showingAIPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI insights")
                            .font(.headline)

                        Text("Choose how many recent records to use.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Stepper(value: $analysisCount, in: 3...20) {
                            Text("Using last \(analysisCount) record\(analysisCount == 1 ? "" : "s")")
                        }

                        Button {
                            guard let session = selectedSession else { return }
                            let entries = fetchEntries(for: session)
                            guard !entries.isEmpty else { return }
                            let request = ParentAIRequest(
                                kind: .trendSummary,
                                childName: session.childName,
                                ageDisplay: computedAgeString(for: session),
                                lastN: analysisCount,
                                note: buildCaregiverNote(session: session, entries: entries, lastN: analysisCount)
                            )
                            showingAIPopover = false
                            DispatchQueue.main.async {
                                activeAIRequest = request
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundStyle(Color.green.opacity(0.38))
                                Text("Trend Summary")
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedSession == nil || fetchEntries(for: selectedSession!).isEmpty)

                        Button {
                            guard let session = selectedSession else { return }
                            let entries = fetchEntries(for: session)
                            guard !entries.isEmpty else { return }
                            let request = ParentAIRequest(
                                kind: .redFlagAssessment,
                                childName: session.childName,
                                ageDisplay: computedAgeString(for: session),
                                lastN: analysisCount,
                                note: buildCaregiverNote(session: session, entries: entries, lastN: analysisCount)
                            )
                            showingAIPopover = false
                            DispatchQueue.main.async {
                                activeAIRequest = request
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "cross.case")
                                    .foregroundStyle(Color.green.opacity(0.38))
                                Text("Red Flag Assessment")
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedSession == nil || fetchEntries(for: selectedSession!).isEmpty)
                    }
                    .padding(16)
                    .frame(width: 300)
                    .presentationCompactAdaptation(.popover)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !activeSessions.isEmpty {
                    Menu {
                        ForEach(activeSessions, id: \.persistentModelID) { session in
                            Button {
                                selectedSessionID = session.persistentModelID
                            } label: {
                                if session.persistentModelID == selectedSession?.persistentModelID {
                                    Label(session.childName, systemImage: "checkmark")
                                } else {
                                    Text(session.childName)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedSession?.childName ?? "Choose child")
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewSessionSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add new child")
            }
        }
        .alert("Delete this child?", isPresented: $showingDeleteChildConfirmation) {
            Button("Cancel", role: .cancel) {
                withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.86, blendDuration: 0.18)) {
                    cardSwipeOffset = 0
                }
            }
            Button("Delete", role: .destructive) {
                deleteSelectedSession()
            }
        } message: {
            Text("This will move the selected child and its records to Recently Deleted.")
        }
        .sheet(isPresented: $showingNewSessionSheet) {
            NavigationStack {
                Form {
                    Section("New child") {
                        TextField("Child name", text: $newChildName)
                            .textInputAutocapitalization(.words)

                        Toggle("Add date of birth", isOn: $hasDateOfBirth)

                        if hasDateOfBirth {
                            DatePicker(
                                "Date of birth",
                                selection: $dateOfBirth,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                        }
                    }
                }
                .navigationTitle("New Session")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            newChildName = ""
                            hasDateOfBirth = false
                            dateOfBirth = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
                            showingNewSessionSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            let trimmed = newChildName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            let dob: Date? = hasDateOfBirth ? dateOfBirth : nil
                            let session = Session(childName: trimmed, dateOfBirth: dob)
                            ctx.insert(session)
                            try? ctx.save()
                            selectedSessionID = session.persistentModelID
                            newChildName = ""
                            hasDateOfBirth = false
                            dateOfBirth = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
                            showingNewSessionSheet = false
                        }
                        .disabled(newChildName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.fraction(0.35), .medium])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(58)
        }
        .sheet(isPresented: $showingQuickRecordSheet) {
            if let session = selectedSession, selectedSessionID != nil {
                NavigationStack {
                    RecordEntryView(session: session)
                }
            }
        }
        .sheet(item: $activeAIRequest) { request in
            NavigationStack {
                switch request.kind {
                case .trendSummary:
                    TrendSummaryResultView(
                        childName: request.childName,
                        ageDisplay: request.ageDisplay,
                        lastN: request.lastN,
                        note: request.note
                    )
                    .id("parent-trend-summary-\(request.note)")
                    .presentationDetents([.fraction(0.35), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(58)
                case .redFlagAssessment:
                    RedFlagAssessmentView(
                        childName: request.childName,
                        ageDisplay: request.ageDisplay,
                        lastN: request.lastN,
                        note: request.note
                    )
                    .id("parent-red-flag-\(request.note)")
                    .presentationDetents([.fraction(0.5), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(58)
                }
            }
        }
        .task(id: activeSessions.map(\.persistentModelID)) {
            let ids = activeSessions.map(\.persistentModelID)
            guard !ids.isEmpty else {
                selectedSessionID = nil
                return
            }

            if let selectedSessionID, ids.contains(selectedSessionID) {
                return
            }

            selectedSessionID = ids.first
        }
        .onChange(of: activeSessions.map(\.persistentModelID)) { _, ids in
            guard !ids.isEmpty else {
                selectedSessionID = nil
                return
            }
            if let selectedSessionID, ids.contains(selectedSessionID) {
                return
            }
            cardSwipeOffset = 0
            self.selectedSessionID = ids.first
            cardSwipeOffset = 0
        }
    }

    @ViewBuilder
    private func swipeableHeaderCard(for session: Session) -> some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.red.opacity(0.14))
                .overlay(alignment: .trailing) {
                    Button {
                        showingDeleteChildConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.red)
                            .frame(width: 72)
                            .frame(maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                }

            headerCard(for: session)
                .offset(x: cardSwipeOffset)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation < 0 {
                                cardSwipeOffset = max(translation * 0.92, -92)
                            } else {
                                cardSwipeOffset = min(cardSwipeOffset + (translation * 0.08), 0)
                            }
                        }
                        .onEnded { value in
                            let predicted = value.predictedEndTranslation.width
                            withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.86, blendDuration: 0.18)) {
                                if predicted < -90 || value.translation.width < -60 {
                                    cardSwipeOffset = -92
                                } else {
                                    cardSwipeOffset = 0
                                }
                            }
                        }
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func deleteSelectedSession() {
        guard let session = selectedSession else { return }
        session.isDeleted = true
        session.deletedAt = Date()
        try? ctx.save()

        showingAIPopover = false
        showingQuickRecordSheet = false
        cardSwipeOffset = 0

        let remaining = activeSessions.filter { $0.persistentModelID != session.persistentModelID }
        selectedSessionID = remaining.first?.persistentModelID
    }

    @ViewBuilder
    private func headerCard(for session: Session) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text(session.childName)
                    .font(.largeTitle.bold())

                HStack(spacing: 12) {
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                            Text("History")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 92)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        showingQuickRecordSheet = true
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "pencil.and.outline")
                                .font(.title2)
                            Text("Record")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 92)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if let latestEntry {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Latest record")
                        .font(.headline)

                    HStack {
                        Text("\(latestEntry.scale.rawValue) • \(latestEntry.score)/10")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(latestEntry.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if !latestEntry.symptoms.isEmpty {
                        Text("Symptoms: \(latestEntry.symptoms.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !latestEntry.locations.isEmpty {
                        Text("Areas: \(latestEntry.locations.map(displayLocationText).joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("No records yet for this child.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }


    @ViewBuilder
    private func insightCards(for session: Session) -> some View {
        let entries = recentEntries
        let symptomCounts = Dictionary(grouping: entries.flatMap(\.symptoms), by: { $0 }).mapValues(\.count)
        let triggerCounts = Dictionary(grouping: entries.flatMap(\.triggers), by: { $0 }).mapValues(\.count)
        let relieverCounts = Dictionary(grouping: entries.flatMap(\.relievers), by: { $0 }).mapValues(\.count)
        let nonZeroScores = entries.map(\.score).filter { $0 > 0 }
        let averageScore = nonZeroScores.isEmpty ? nil : Double(nonZeroScores.reduce(0, +)) / Double(nonZeroScores.count)
        let latestSymptoms = latestEntry?.symptoms ?? []
        let topSymptom = symptomCounts.max { lhs, rhs in lhs.value < rhs.value }
        let topTrigger = triggerCounts.max { lhs, rhs in lhs.value < rhs.value }
        let topReliever = relieverCounts.max { lhs, rhs in lhs.value < rhs.value }

        VStack(alignment: .leading, spacing: 12) {
            Text("Helpful insights")
                .font(.headline)

            recentPatternGraphCard(for: session, averageScore: averageScore)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                insightCard(
                    title: "Common symptom",
                    systemImage: "stethoscope",
                    text: topSymptom.map { "\($0.key) appeared in \($0.value) recent record\($0.value == 1 ? "" : "s")." } ?? "No repeated symptom has been recorded recently."
                )

                insightCard(
                    title: "Possible trigger",
                    systemImage: "exclamationmark.bubble",
                    text: topTrigger.map { "\($0.key) was logged \($0.value) time\($0.value == 1 ? "" : "s")." } ?? "No trigger trend has been recorded yet."
                )

                insightCard(
                    title: "What helped",
                    systemImage: "cross.case",
                    text: topReliever.map { "\($0.key) was logged as helpful \($0.value) time\($0.value == 1 ? "" : "s")." } ?? "No reliever trend has been recorded yet."
                )

                insightCard(
                    title: "Latest check-in",
                    systemImage: "clock",
                    text: !latestSymptoms.isEmpty ? "Most recent symptoms: \(latestSymptoms.joined(separator: ", "))." : "No recent symptoms were logged in the latest check-in."
                )
            }
        }
    }

    private func recentEntriesForAI(_ session: Session) -> [PainEntry] {
        fetchEntries(for: session)
    }

    private func fetchEntries(for session: Session) -> [PainEntry] {
        let sid = session.persistentModelID

        let fetchedDescriptor = FetchDescriptor<PainEntry>(
            predicate: #Predicate<PainEntry> { entry in
                !entry.isDeleted
            },
            sortBy: [SortDescriptor(\PainEntry.timestamp, order: .reverse)]
        )
        let fetchedAllActiveEntries = (try? ctx.fetch(fetchedDescriptor)) ?? []

        let queryFilteredEntries = allEntries.filter {
            !$0.isDeleted && $0.session?.persistentModelID == sid
        }

        let fetchedFilteredEntries = fetchedAllActiveEntries.filter {
            $0.session?.persistentModelID == sid
        }

        let relationshipEntries = session.entries.filter { !$0.isDeleted }

        let combined = queryFilteredEntries + fetchedFilteredEntries + relationshipEntries
        var seen = Set<PersistentIdentifier>()
        return combined
            .filter { seen.insert($0.persistentModelID).inserted }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private func latestEntryDate(for session: Session) -> Date? {
        fetchEntries(for: session).first?.timestamp
    }

    private func computedAgeString(for session: Session) -> String? {
        guard let dob = session.dateOfBirth else { return nil }
        let components = Calendar.current.dateComponents([.year, .month], from: dob, to: Date())
        let years = max(components.year ?? 0, 0)
        let months = max(components.month ?? 0, 0)

        if years > 0 {
            return months > 0 ? "\(years)y \(months)m" : "\(years)y"
        } else {
            return "\(months)m"
        }
    }

    private func buildCaregiverNote(session: Session, entries: [PainEntry], lastN: Int) -> String {
        let recent = Array(entries.prefix(lastN))

        let df = DateFormatter()
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
        let scoreText = scores.isEmpty ? "none" : scores.map(String.init).joined(separator: " → ")
        let maxScore = scores.max() ?? 0
        let minScore = scores.min() ?? 0

        var lines: [String] = []
        lines.append("Child: \(session.childName).")
        lines.append("Recent scores (latest→older): \(scoreText). Range: \(minScore)–\(maxScore)/10.")
        lines.append("Records:")

        for e in recent {
            let when = df.string(from: e.timestamp)
            let notesShort = clipped(e.notes)
            let medicationLine = medicationSummary(for: e)

            lines.append("""
            - \(when): score \(e.score)/10 (\(e.scale.rawValue)); trend: \(e.trend); duration: \(e.durationMinutes) min;
              locations: \(joinOr(e.locations.map(displayLocationText), empty: "unknown"));
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

    private func recentPatternText(for session: Session, averageScore: Double?) -> String {
        guard !recentEntries.isEmpty else {
            return "Add more records to start seeing trends here."
        }

        if let latestEntry {
            if latestEntry.score == 0 {
                return "The most recent record was 0/10, which may suggest your child felt more comfortable at that time."
            }

            if let averageScore {
                return "The latest score was \(latestEntry.score)/10. Recent non-zero scores averaged about \(Int(averageScore.rounded()))/10."
            }

            return "The latest score was \(latestEntry.score)/10. Add a few more records to build a clearer trend."
        }

        return "Add more records to start seeing trends here."
    }

    private struct RecentPatternPoint: Identifiable {
        let id = UUID()
        let index: Int
        let score: Int
    }

    @ViewBuilder
    private func recentPatternGraphCard(for session: Session, averageScore: Double?) -> some View {
        let points = recentPatternPoints(for: session)

        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .foregroundStyle(Color.green.opacity(0.38))
                Text("Recent pain pattern")
                    .font(.headline)
            }

            if points.isEmpty {
                Text("Add more records to start seeing trends here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Chart(points) { point in
                    LineMark(
                        x: .value("Record", point.index),
                        y: .value("Score", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.green.opacity(0.38))

                    AreaMark(
                        x: .value("Record", point.index),
                        y: .value("Score", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.green.opacity(0.12))

                    PointMark(
                        x: .value("Record", point.index),
                        y: .value("Score", point.score)
                    )
                    .foregroundStyle(Color.green.opacity(0.38))
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 2, 4, 6, 8, 10])
                }
                .chartYScale(domain: 0...10)
                .frame(height: 120)

                Text(recentPatternText(for: session, averageScore: averageScore))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func recentPatternPoints(for session: Session) -> [RecentPatternPoint] {
        let ordered = recentEntries.reversed()
        return Array(ordered.enumerated()).map { offset, entry in
            RecentPatternPoint(index: offset + 1, score: entry.score)
        }
    }

    private func insightCard(title: String, systemImage: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(Color.green.opacity(0.38))
                Text(title)
                    .font(.headline)
            }

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No children yet")
                .font(.headline)
            Text("Create or import a child profile to start recording and reviewing recent history here.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func displayLocationText(_ raw: String) -> String {
        if let location = PainLocation(rawValue: raw) {
            return location.displayName
        }

        let separated = raw.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
        return separated.prefix(1).uppercased() + separated.dropFirst()
    }

    private func medicationDisplayLines(for entry: PainEntry) -> [String] {
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
            lines.append("Next reminder: \(reminderDate.formatted(date: .abbreviated, time: .shortened))")
        }

        return lines
    }
}
