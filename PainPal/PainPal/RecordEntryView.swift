//
//  RecordEntryView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData
import UserNotifications

struct RecordEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    let session: Session


    private func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    private func scheduleNotificationsIfNeeded(for entry: PainEntry) {
        print("=== Scheduling notifications for entry ===")
        print("Symptoms:", entry.symptoms)
        print("Triggers:", entry.triggers)
        print("Relievers:", entry.relievers)
        print("Medicine taken:", entry.medicineTaken)
        print("Medicine name:", entry.medicineName)
        print("Next medication reminder date:", String(describing: entry.nextMedicationReminderDate))

        let recentEntries = session.entries
            .filter { !$0.isDeleted && $0.persistentModelID != entry.persistentModelID }
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(5)

        let plans = EntryNotificationBuilder.buildPlans(
            for: entry,
            recentEntries: Array(recentEntries)
        )

        print("Recent entries considered:", recentEntries.count)
        print("Notification plans generated:", plans.count)
        for plan in plans {
            print("- [\(plan.id)] \(plan.title) | delay: \(plan.timeInterval)s")
            print("  body: \(plan.body)")
        }

        NotificationManager.shared.scheduleAll(plans)
        print("=== Finished scheduling notifications ===")
    }


    // If non-nil, the view edits an existing entry instead of creating a new one.
    private var editingEntry: PainEntry?
    
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: FocusField?

    @State private var scale: PainScale = .rFLACC
    @State private var score: Int = 0
    @State private var notes: String = ""

    // prototype placeholders (we’ll replace with speech + Apple FM)
    @State private var transcript: String = ""
    @State private var aiSummary: String = ""

    // Structured pain details
    @State private var trend: String = PainTrend.same.rawValue
    @State private var durationMinutes: Int = 0

    // Multi-select fields (stored on PainEntry as [String])
    @State private var selectedLocations: Set<String> = []
    @State private var otherLocation: String = ""
    @State private var locationInputMode: LocationInputMode = .hybrid

    @State private var selectedQualities: Set<String> = []
    @State private var otherQuality: String = ""

    @State private var selectedSymptoms: Set<String> = []
    @State private var otherSymptom: String = ""

    @State private var selectedTriggers: Set<String> = []
    @State private var otherTrigger: String = ""


    @State private var selectedRelievers: Set<String> = []
    @State private var otherReliever: String = ""

    // Medication fields
    @State private var medicineTaken: Bool = false
    @State private var medicineName: String = ""
    @State private var hasNextMedicationReminder: Bool = false
    @State private var nextMedicationReminderDate: Date = Date().addingTimeInterval(60 * 60)
    @State private var medicationInstructions: String = ""


    private var durationText: String {
        if durationMinutes <= 0 { return "Just started" }
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }


    private func durationOptionLabel(_ minutes: Int) -> String {
        if minutes <= 0 { return "Just started" }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(mins)m"
    }

    private let durationHourOptions: [Int] = Array(0...24)
    private let durationMinuteOptions: [Int] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]

    private var selectedDurationHours: Binding<Int> {
        Binding(
            get: { durationMinutes / 60 },
            set: { newHours in
                let currentMinutes = durationMinutes % 60
                durationMinutes = (newHours * 60) + currentMinutes
            }
        )
    }

    private var selectedDurationRemainderMinutes: Binding<Int> {
        Binding(
            get: { durationMinutes % 60 },
            set: { newMinutes in
                let currentHours = durationMinutes / 60
                durationMinutes = (currentHours * 60) + newMinutes
            }
        )
    }

    private enum LocationInputMode: String, CaseIterable, Identifiable {
        case text = "Text"
        case diagram = "Body Diagram"
        case hybrid = "Hybrid"

        var id: String { rawValue }
    }

    private enum FocusField: Hashable {
        case otherLocation
        case otherQuality
        case otherSymptom
        case otherTrigger
        case otherReliever
        case medicineName
        case medicationInstructions
        case notes
    }

    private var predefinedLocationValues: Set<String> {
        Set(PainLocation.allCases.map { $0.rawValue })
    }

    private var diagramSelection: Binding<Set<PainLocation>> {
        Binding<Set<PainLocation>>(
            get: {
                Set(selectedLocations.compactMap(PainLocation.init(rawValue:)))
            },
            set: { newValue in
                let customLocations = selectedLocations.filter { !predefinedLocationValues.contains($0) }
                selectedLocations = customLocations.union(Set(newValue.map(\.rawValue)))
            }
        )
    }

    @ViewBuilder
    private var painLocationSection: some View {
        Section {
            if locationInputMode == .hybrid {
                BodyDiagramSelectorView(selectedLocations: diagramSelection)
                    .padding(.vertical, 4)
            }

            if locationInputMode == .hybrid {
                HStack {
                    TextField("Other location…", text: $otherLocation)
                        .focused($focusedField, equals: .otherLocation)
                        .submitLabel(.done)
                        .onSubmit {
                            let trimmed = otherLocation.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            selectedLocations.insert(trimmed)
                            otherLocation = ""
                            focusedField = nil
                        }

                    Button {
                        let trimmed = otherLocation.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        selectedLocations.insert(trimmed)
                        otherLocation = ""
                        focusedField = nil
                    } label: {
                        Text("Add")
                    }
                    .buttonStyle(.bordered)
                    .disabled(otherLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            let customItems = selectedLocations
                .filter { !predefinedLocationValues.contains($0) }
                .sorted()

            if !customItems.isEmpty {
                ForEach(customItems, id: \.self) { item in
                    Toggle(item, isOn: Binding(
                        get: { selectedLocations.contains(item) },
                        set: { isOn in
                            if isOn { selectedLocations.insert(item) } else { selectedLocations.remove(item) }
                        }
                    ))
                }
            }
        } header: {
            Text("Pain areas")
        }
        footer: {
            Text("Choose pain areas on the body diagram or add a custom location.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }



    private struct MultiSelectSection<Option>: View
    where Option: CaseIterable & Identifiable & RawRepresentable, Option.RawValue == String {

        let title: String
        let footer: String
        let pickerLabel: String
        let otherPlaceholder: String

        @Binding var selection: Set<String>
        @Binding var otherText: String
        let focus: FocusState<FocusField?>.Binding
        let focusField: FocusField
        @State private var isExpanded = false
        @State private var storedCustomItems: [String] = []

        private let columns: [GridItem] = [
            GridItem(.adaptive(minimum: 110), spacing: 10, alignment: .leading)
        ]

        private var predefinedItems: [String] {
            Array(Option.allCases.map { $0.rawValue }).sorted()
        }

        private var customItems: [String] {
            storedCustomItems.sorted()
        }

        private var allItems: [String] {
            predefinedItems + customItems
        }

        private var selectionSummary: String {
            let items = selection.sorted()
            if items.isEmpty { return "None selected" }
            if items.count <= 3 { return items.joined(separator: ", ") }
            return "\(items.prefix(3).joined(separator: ", ")) +\(items.count - 3) more"
        }

        private var storageKey: String {
            "painpal.custom.\(String(describing: Option.self))"
        }

        private func toggle(_ item: String) {
            if selection.contains(item) {
                selection.remove(item)
            } else {
                selection.insert(item)
            }
        }

        private func loadCustomItems() {
            let saved = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
            storedCustomItems = Array(Set(saved)).sorted()
        }

        private func saveCustomItems() {
            UserDefaults.standard.set(storedCustomItems.sorted(), forKey: storageKey)
        }

        private func addOther() {
            let trimmed = otherText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            if !predefinedItems.contains(trimmed) && !storedCustomItems.contains(trimmed) {
                storedCustomItems.append(trimmed)
                storedCustomItems.sort()
                saveCustomItems()
            }

            selection.insert(trimmed)
            otherText = ""
        }

        var body: some View {
            Section {
                DisclosureGroup(isExpanded: $isExpanded) {
                    VStack(alignment: .leading, spacing: 14) {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                            ForEach(allItems, id: \.self) { item in
                                Button {
                                    toggle(item)
                                } label: {
                                    Text(item)
                                        .font(.subheadline)
                                        .foregroundStyle(selection.contains(item) ? Color.white : Color.primary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(selection.contains(item) ? Color.green : Color.gray.opacity(0.18))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(selection.contains(item) ? Color.green : Color.gray.opacity(0.25), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        HStack {
                            TextField(otherPlaceholder, text: $otherText)
                                .focused(focus, equals: focusField)
                                .submitLabel(.done)
                                .onSubmit {
                                    addOther()
                                    focus.wrappedValue = nil
                                }

                            Button {
                                addOther()
                                focus.wrappedValue = nil
                            } label: {
                                Text("Add")
                            }
                            .buttonStyle(.bordered)
                            .disabled(otherText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pickerLabel)
                            .foregroundStyle(.primary)

                        Text(selectionSummary)
                            .font(.footnote)
                            .foregroundStyle(selection.isEmpty ? .secondary : .primary)
                            .lineLimit(2)
                    }
                }
            } header: {
                Text(title)
            } footer: {
                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .onAppear {
                loadCustomItems()
            }
        }
    }

    init(session: Session, editingEntry: PainEntry? = nil) {
        self.session = session
        self.editingEntry = editingEntry

        if let e = editingEntry {
            _scale = State(initialValue: e.scale)
            _score = State(initialValue: e.score)
            _notes = State(initialValue: e.notes)

            _transcript = State(initialValue: e.transcript ?? "")
            _aiSummary = State(initialValue: e.aiSummary ?? "")

            _trend = State(initialValue: e.trend)
            _durationMinutes = State(initialValue: e.durationMinutes)

            _selectedLocations = State(initialValue: Set(e.locations))
            _selectedQualities = State(initialValue: Set(e.qualityWords))
            _selectedSymptoms = State(initialValue: Set(e.symptoms))
            _selectedTriggers = State(initialValue: Set(e.triggers))
            _selectedRelievers = State(initialValue: Set(e.relievers))

            // Clear the "other" text fields when editing.
            _otherLocation = State(initialValue: "")
            _otherQuality = State(initialValue: "")
            _otherSymptom = State(initialValue: "")
            _otherTrigger = State(initialValue: "")
            _otherReliever = State(initialValue: "")
            _locationInputMode = State(initialValue: .hybrid)
            // Preload medication fields when editing an existing entry.
            _medicineTaken = State(initialValue: e.medicineTaken)
            _medicineName = State(initialValue: e.medicineName)
            _hasNextMedicationReminder = State(initialValue: e.nextMedicationReminderDate != nil)
            _nextMedicationReminderDate = State(initialValue: e.nextMedicationReminderDate ?? Date().addingTimeInterval(60 * 60))
            _medicationInstructions = State(initialValue: e.medicationInstructions)
        } else {
            // New entry
            _locationInputMode = State(initialValue: .hybrid)
            self.editingEntry = nil
            _medicineTaken = State(initialValue: false)
            _medicineName = State(initialValue: "")
            _hasNextMedicationReminder = State(initialValue: false)
            _nextMedicationReminderDate = State(initialValue: Date().addingTimeInterval(60 * 60))
            _medicationInstructions = State(initialValue: "")
        }
    }

    var body: some View {
        Form {
            painLocationSection

            Section {
                Picker("Scale", selection: $scale) {
                    ForEach(PainScale.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }

                if scale == .wongBaker {
                    Image(colorScheme == .dark
                          ? "FACES_English_Black_w-instructions-bg-removed-inverted"
                          : "FACES_English_Black_w-instructions-bg-removed")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Score")
                        Spacer()
                        Text("\(score)/10")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    Slider(
                        value: Binding(
                            get: { Double(score) },
                            set: { score = Int($0.rounded()) }
                        ),
                        in: 0...10,
                        step: 1
                    )
                    .accessibilityLabel("Pain score")
                    .accessibilityValue("\(score) out of 10")
                }

                Picker("Trend", selection: $trend) {
                    ForEach(PainTrend.allCases) { t in
                        Text(t.rawValue).tag(t.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(durationText)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    HStack(spacing: 0) {
                        Picker("Hours", selection: selectedDurationHours) {
                            ForEach(durationHourOptions, id: \.self) { hour in
                                Text("\(hour) h").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()

                        Picker("Minutes", selection: selectedDurationRemainderMinutes) {
                            ForEach(durationMinuteOptions, id: \.self) { minute in
                                Text("\(minute) m").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    .frame(height: 120)
                }
            } header: {
                Text("Pain Assessment")
            }

            MultiSelectSection<PainQuality>(
                title: "Pain quality",
                footer: "Examples: sharp, dull, throbbing, burning.",
                pickerLabel: "Choose qualities",
                otherPlaceholder: "Other quality…",
                selection: $selectedQualities,
                otherText: $otherQuality,
                focus: $focusedField,
                focusField: .otherQuality
            )

            MultiSelectSection<Symptom>(
                title: "Symptoms",
                footer: "Pick any associated symptoms. Add 'other' if it’s not listed.",
                pickerLabel: "Choose symptoms",
                otherPlaceholder: "Other symptom…",
                selection: $selectedSymptoms,
                otherText: $otherSymptom,
                focus: $focusedField,
                focusField: .otherSymptom
            )

            MultiSelectSection<Trigger>(
                title: "Triggers",
                footer: "What seems to make it worse?",
                pickerLabel: "Choose triggers",
                otherPlaceholder: "Other trigger…",
                selection: $selectedTriggers,
                otherText: $otherTrigger,
                focus: $focusedField,
                focusField: .otherTrigger
            )

            MultiSelectSection<Reliever>(
                title: "Relievers",
                footer: "What seems to help?",
                pickerLabel: "Choose relievers",
                otherPlaceholder: "Other reliever…",
                selection: $selectedRelievers,
                otherText: $otherReliever,
                focus: $focusedField,
                focusField: .otherReliever
            )

            Section {
                Toggle("Medicine taken", isOn: $medicineTaken)

                if medicineTaken {
                    TextField("Medicine name", text: $medicineName)
                        .focused($focusedField, equals: .medicineName)
                        .submitLabel(.done)

                    Toggle("Set next medication reminder", isOn: $hasNextMedicationReminder)

                    if hasNextMedicationReminder {
                        DatePicker(
                            "Next reminder",
                            selection: $nextMedicationReminderDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }

                    TextField("Instructions (e.g. after food)", text: $medicationInstructions, axis: .vertical)
                        .focused($focusedField, equals: .medicationInstructions)
                        .lineLimit(2...4)
                }
            } header: {
                Text("Medication")
            } footer: {
                Text("Log medicine taken, an optional next reminder time, and any caregiver instructions.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                TextEditor(text: $notes)
                    .focused($focusedField, equals: .notes)
                    .frame(minHeight: 90)
            } header: {
                Text("Notes")
            } footer: {
                Text("Used for smart summarisation and further details.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

//            Section("Voice / AI (prototype)") {
//                TextField("Transcript (optional)", text: $transcript, axis: .vertical)
//                TextField("AI summary (optional)", text: $aiSummary, axis: .vertical)
//            }
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(editingEntry == nil ? "Save" : "Update") {
                    if let e = editingEntry {
                        e.scale = scale
                        e.score = score
                        e.notes = notes

                        let t = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                        e.transcript = t.isEmpty ? nil : t

                        let s = aiSummary.trimmingCharacters(in: .whitespacesAndNewlines)
                        e.aiSummary = s.isEmpty ? nil : s

                        e.trend = trend
                        e.durationMinutes = durationMinutes
                        e.locations = Array(selectedLocations).sorted()
                        e.qualityWords = Array(selectedQualities).sorted()
                        e.symptoms = Array(selectedSymptoms).sorted()
                        e.triggers = Array(selectedTriggers).sorted()
                        e.relievers = Array(selectedRelievers).sorted()
                        e.medicineTaken = medicineTaken
                        e.medicineName = medicineName.trimmingCharacters(in: .whitespacesAndNewlines)
                        e.nextMedicationReminderDate = medicineTaken && hasNextMedicationReminder ? nextMedicationReminderDate : nil
                        e.medicationInstructions = medicationInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
                        e.isDeleted = false

                        try? ctx.save()
                        requestNotificationPermissionIfNeeded()

                        if let reminderDate = e.nextMedicationReminderDate,
                           e.medicineTaken,
                           !e.medicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            print("Scheduling medication reminder for edited entry:", e.medicineName, "at", reminderDate)
                            NotificationManager.shared.scheduleMedicationReminder(
                                entryID: UUID(),
                                childName: session.childName,
                                medicineName: e.medicineName,
                                instructions: e.medicationInstructions,
                                reminderDate: reminderDate
                            )
                        }

                        dismiss()
                    } else {
                        let entry = PainEntry(
                            scale: scale,
                            score: score,
                            notes: notes,
                            transcript: transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : transcript,
                            aiSummary: aiSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : aiSummary,
                            trend: trend,
                            durationMinutes: durationMinutes,
                            locations: Array(selectedLocations).sorted(),
                            qualityWords: Array(selectedQualities).sorted(),
                            symptoms: Array(selectedSymptoms).sorted(),
                            triggers: Array(selectedTriggers).sorted(),
                            relievers: Array(selectedRelievers).sorted(),
                            medicineTaken: medicineTaken,
                            medicineName: medicineName.trimmingCharacters(in: .whitespacesAndNewlines),
                            nextMedicationReminderDate: medicineTaken && hasNextMedicationReminder ? nextMedicationReminderDate : nil,
                            medicationInstructions: medicationInstructions.trimmingCharacters(in: .whitespacesAndNewlines),
                            session: session
                        )
                        ctx.insert(entry)
                        try? ctx.save()
                        requestNotificationPermissionIfNeeded()
                        scheduleNotificationsIfNeeded(for: entry)

                        if let reminderDate = entry.nextMedicationReminderDate,
                           entry.medicineTaken,
                           !entry.medicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            print("Scheduling medication reminder for new entry:", entry.medicineName, "at", reminderDate)
                            NotificationManager.shared.scheduleMedicationReminder(
                                entryID: UUID(),
                                childName: session.childName,
                                medicineName: entry.medicineName,
                                instructions: entry.medicationInstructions,
                                reminderDate: reminderDate
                            )
                        }

                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("RecordEntryView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, PainEntry.self, configurations: config)
    let ctx = container.mainContext

    let s = Session(childName: "Amy")
    ctx.insert(s)

    return NavigationStack {
        RecordEntryView(session: s)
    }
    .modelContainer(container)
}
