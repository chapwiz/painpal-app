//
//  RedFlagAssessmentView.swift
//  PainPal
//
//  Created by Chapman Leung on 24/3/2026.
//

import SwiftUI

struct RedFlagAssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    private let ai = PainPalAIClient()
    @State private var isRunning = false
    @State private var result: PainPalAssessment?
    @State private var errorText: String?

    let childName: String
    let ageDisplay: String?
    let lastN: Int
    let note: String

    private func runAssessment() {
        guard !isRunning, !note.isEmpty else { return }
        Task {
            errorText = nil
            isRunning = true
            defer { isRunning = false }
            do {
                result = try await ai.assess(from: note)
            } catch {
                errorText = String(describing: error)
            }
        }
    }

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

            Section("AI") {
                Button(isRunning ? "Analysing..." : "Assess red flags / next steps") {
                    runAssessment()
                }
                .disabled(isRunning || note.isEmpty)

                if let err = errorText {
                    Text(err)
                        .foregroundStyle(.red)
                }
            }

            if let a = result {
                Section("Assessment") {
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
        .navigationTitle("Red Flag Assessment")
        .task {
            runAssessment()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
