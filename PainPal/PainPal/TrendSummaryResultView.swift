//
//  TrendSummaryResultView.swift
//  PainPal
//
//  Created by Chapman Leung on 24/3/2026.
//

import SwiftUI

struct TrendSummaryResultView: View {
    @Environment(\.dismiss) private var dismiss
    private let ai = PainPalAIClient()
    @State private var isRunning = false
    @State private var result: TrendSummary?
    @State private var errorText: String?

    let childName: String
    let ageDisplay: String?
    let lastN: Int
    let note: String

    private func runTrendSummary() {
        guard !isRunning, !note.isEmpty else { return }
        Task {
            errorText = nil
            isRunning = true
            defer { isRunning = false }
            do {
                result = try await ai.summariseTrend(from: note)
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
                Button(isRunning ? "Summarising..." : "Summarise trend") {
                    runTrendSummary()
                }
                .disabled(isRunning || note.isEmpty)

                if let err = errorText {
                    Text(err)
                        .foregroundStyle(.red)
                }
            }

            if let t = result {
                Section("Trend Summary") {
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
        }
        .navigationTitle("Trend Summary")
        .task {
            runTrendSummary()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
