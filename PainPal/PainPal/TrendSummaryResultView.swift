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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isRunning {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Summarising trend...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else if let err = errorText {
                    Text(err)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else if let t = result {
                    Text(t.oneParagraphSummary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    Text("No trend summary available.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
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
