//
//  RecordEntryView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData
import MultiPicker

struct RecordEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @Bindable var session: Session
    
    @Environment(\.colorScheme) private var colorScheme

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



    private struct MultiSelectSection<Option>: View
    where Option: CaseIterable & Identifiable & RawRepresentable, Option.RawValue == String {

        let title: String
        let footer: String
        let pickerLabel: String
        let otherPlaceholder: String

        @Binding var selection: Set<String>
        @Binding var otherText: String

        private var predefinedSet: Set<String> {
            Set(Option.allCases.map { $0.rawValue })
        }

        private var customItems: [String] {
            selection
                .filter { !predefinedSet.contains($0) }
                .sorted()
        }

        private func addOther() {
            let trimmed = otherText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            selection.insert(trimmed)
            otherText = ""
        }

        var body: some View {
            Section {
                MultiPicker(pickerLabel, selection: $selection) {
                    ForEach(Array(Option.allCases), id: \.id) { opt in
                        Text(opt.rawValue)
                            .mpTag(opt.rawValue)
                    }
                }
                .mpPickerStyle(.navigationLink)

                HStack {
                    TextField(otherPlaceholder, text: $otherText)
                    Button("Add") { addOther() }
                        .disabled(otherText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if !customItems.isEmpty {
                    Divider()

                    Text("Custom")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ForEach(customItems, id: \.self) { item in
                        Toggle(item, isOn: Binding(
                            get: { selection.contains(item) },
                            set: { isOn in
                                if isOn { selection.insert(item) } else { selection.remove(item) }
                            }
                        ))
                    }
                }
            } header: {
                Text(title)
            } footer: {
                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var body: some View {
        Form {
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

            MultiSelectSection<PainLocation>(
                title: "Pain areas",
                footer: "Select one or more areas. Add a custom area if needed.",
                pickerLabel: "Choose areas",
                otherPlaceholder: "Other location…",
                selection: $selectedLocations,
                otherText: $otherLocation
            )

            MultiSelectSection<PainQuality>(
                title: "Pain quality",
                footer: "Examples: sharp, dull, throbbing, burning.",
                pickerLabel: "Choose qualities",
                otherPlaceholder: "Other quality…",
                selection: $selectedQualities,
                otherText: $otherQuality
            )

            MultiSelectSection<Symptom>(
                title: "Symptoms",
                footer: "Pick any associated symptoms. Add 'other' if it’s not listed.",
                pickerLabel: "Choose symptoms",
                otherPlaceholder: "Other symptom…",
                selection: $selectedSymptoms,
                otherText: $otherSymptom
            )

            MultiSelectSection<Trigger>(
                title: "Triggers",
                footer: "What seems to make it worse?",
                pickerLabel: "Choose triggers",
                otherPlaceholder: "Other trigger…",
                selection: $selectedTriggers,
                otherText: $otherTrigger
            )

            MultiSelectSection<Reliever>(
                title: "Relievers",
                footer: "What seems to help?",
                pickerLabel: "Choose relievers",
                otherPlaceholder: "Other reliever…",
                selection: $selectedRelievers,
                otherText: $otherReliever
            )

            Section {
                TextEditor(text: $notes).frame(minHeight: 90)
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
        .navigationTitle("Record")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let entry = PainEntry(
                        scale: scale,
                        score: score,
                        notes: notes,
                        transcript: transcript.isEmpty ? nil : transcript,
                        aiSummary: aiSummary.isEmpty ? nil : aiSummary,
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
                    dismiss()
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
