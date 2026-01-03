//
//  ExportView.swift
//  PainPal
//
//  Created by Chapman Leung on 3/1/2026.
//

import SwiftUI
import SwiftData

struct ExportView: View {
    var body: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "Export coming soon",
                systemImage: "square.and.arrow.up",
                description: Text("You’ll export a session (PDF/CSV) for clinicians here.")
            )

            // Placeholder action
            Button("Export") { }
                .buttonStyle(.borderedProminent)
                .disabled(true)
        }
        .padding()
        .navigationTitle("Export")
    }
}
