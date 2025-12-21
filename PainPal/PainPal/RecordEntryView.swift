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

    @State private var scale: PainScale = .rFLACC
    @State private var score: Int = 0
    @State private var notes: String = ""

    // prototype placeholders (we’ll replace with speech + Apple FM)
    @State private var transcript: String = ""
    @State private var aiSummary: String = ""

    var body: some View {
        Form {
            Section("Pain") {
                Picker("Scale", selection: $scale) {
                    ForEach(PainScale.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                Stepper("Score: \(score)/10", value: $score, in: 0...10)
            }

            Section("Notes") {
                TextEditor(text: $notes).frame(minHeight: 90)
            }

            Section("Voice / AI (prototype)") {
                TextField("Transcript (optional)", text: $transcript, axis: .vertical)
                TextField("AI summary (optional)", text: $aiSummary, axis: .vertical)
            }
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
