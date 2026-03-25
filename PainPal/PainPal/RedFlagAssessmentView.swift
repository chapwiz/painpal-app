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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isRunning {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Assessing red flags...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else if let err = errorText {
                    Text(err)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else if let a = result {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Danger level: \(a.dangerLevel)")
                            .font(.headline)

                        Text(a.whyThisLevel)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(a.recommendedNextStep)
                            .frame(maxWidth: .infinity, alignment: .leading)

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
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else {
                    Text("No red-flag assessment available.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
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
