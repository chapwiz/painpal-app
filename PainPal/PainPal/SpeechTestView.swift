//
//  SpeechTestView.swift
//  PainPal
//
//  Created by Chapman Leung on 27/1/2026.
//

import SwiftUI

struct SpeechTestView: View {
    @StateObject private var speech = SpeechRecognizer()
    @State private var lastTranscript: String = ""
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Transcript:")
                .font(.headline)

            TextEditor(text: $lastTranscript)
                .focused($isEditorFocused)
                .frame(height: 220)
                .padding(8)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topLeading) {
                    if lastTranscript.isEmpty {
                        Text("—")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 16)
                    }
                }

            HStack {
                Button("Start") {
                    isEditorFocused = false
                    speech.startTranscribing()
                }
                .buttonStyle(.borderedProminent)

                Button("Stop") {
                    isEditorFocused = false
                    speech.stopTranscribing()
                }
                .buttonStyle(.bordered)
            }

            Button("Reset") {
                isEditorFocused = false
                speech.resetTranscript()
                lastTranscript = ""
            }
            .buttonStyle(.bordered)
        }
        .onReceive(speech.$transcript) { value in
            // Only update from recognizer when it produces a non-empty value.
            // This keeps the field editable while still allowing live transcription.
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                lastTranscript = value
            }
        }
        .padding()
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            isEditorFocused = false
        }
    }
}
