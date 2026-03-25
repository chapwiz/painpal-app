//
//  RecordEntryView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData

struct RecordEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @Bindable var session: Session

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

    private var durationText: String {
        if durationMinutes <= 0 { return "Just started" }
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        return "\(minutes)m"
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
        } else {
            // New entry
            _locationInputMode = State(initialValue: .hybrid)
            self.editingEntry = nil
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

                Stepper(value: $durationMinutes, in: 0...24*60, step: 5) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(durationText)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
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
                        // Update existing entry in-place
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

                        // Defensive: ensure it isn't in Recently Deleted
                        e.isDeleted = false

                        try? ctx.save()
                        dismiss()
                    } else {
                        // Create new entry
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
                            session: session
                        )
                        ctx.insert(entry)
                        try? ctx.save()
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
