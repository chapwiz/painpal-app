//
//  PreparedCaregiverNoteView.swift
//  PainPal
//
//  Created by Chapman Leung on 24/3/2026.
//

import SwiftUI
import UIKit

struct PreparedCaregiverNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL?
    @State private var shareFormat: ExportFormat = .pdf
    @State private var isShowingFullNote = false

    let childName: String
    let ageDisplay: String?
    let lastN: Int
    let note: String

    private enum ExportFormat: String, CaseIterable, Identifiable {
        case pdf = "PDF"
        case text = "TXT"

        var id: String { rawValue }
    }

    private var recordCountText: String {
        "Using last \(lastN) record\(lastN == 1 ? "" : "s")"
    }

    private var notePreviewText: String {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 220 else { return trimmed }
        let endIndex = trimmed.index(trimmed.startIndex, offsetBy: 220)
        return String(trimmed[..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private var displayedNoteText: String {
        isShowingFullNote ? note : notePreviewText
    }

    private var canExpandNote: Bool {
        notePreviewText != note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(childName)
                .font(.title2.weight(.semibold))

            Text(recordCountText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: "doc.text")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Prepared caregiver note")
                        .font(.headline)
                    Text("Ready to review, copy, or share")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(displayedNoteText)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)

            if canExpandNote {
                Button {
                    isShowingFullNote.toggle()
                } label: {
                    Text(isShowingFullNote ? "Show less" : "View full note")
                        .font(.footnote.weight(.semibold))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var exportFileNameBase: String {
        childName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .lowercased()
            .appending("_caregiver_note")
    }

    private var exportText: String {
        var lines: [String] = []
        lines.append("Caregiver Note")
        lines.append("")
        lines.append("Child: \(childName)")
        if let ageDisplay {
            lines.append("Age: \(ageDisplay)")
        }
        lines.append(recordCountText)
        lines.append("")
        lines.append(note)
        return lines.joined(separator: "\n")
    }

    private func makeTemporaryTextFile() -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(exportFileNameBase)
            .appendingPathExtension("txt")

        do {
            try exportText.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private func makeTemporaryPDFFile() -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(exportFileNameBase)
            .appendingPathExtension("pdf")

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 at 72 dpi
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()

                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 22)
                ]
                let headingAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 13)
                ]
                let bodyAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12)
                ]
                let secondaryAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11),
                    .foregroundColor: UIColor.secondaryLabel
                ]

                let left: CGFloat = 48
                let right: CGFloat = 48
                let width = pageRect.width - left - right
                var y: CGFloat = 52

                NSString(string: "Caregiver Note").draw(
                    in: CGRect(x: left, y: y, width: width, height: 28),
                    withAttributes: titleAttributes
                )
                y += 36

                NSString(string: "Child").draw(
                    in: CGRect(x: left, y: y, width: width, height: 18),
                    withAttributes: headingAttributes
                )
                y += 18
                NSString(string: childName).draw(
                    in: CGRect(x: left, y: y, width: width, height: 18),
                    withAttributes: bodyAttributes
                )
                y += 26

                if let ageDisplay {
                    NSString(string: "Age").draw(
                        in: CGRect(x: left, y: y, width: width, height: 18),
                        withAttributes: headingAttributes
                    )
                    y += 18
                    NSString(string: ageDisplay).draw(
                        in: CGRect(x: left, y: y, width: width, height: 18),
                        withAttributes: bodyAttributes
                    )
                    y += 26
                }

                NSString(string: recordCountText).draw(
                    in: CGRect(x: left, y: y, width: width, height: 18),
                    withAttributes: secondaryAttributes
                )
                y += 28

                NSString(string: "Prepared caregiver note").draw(
                    in: CGRect(x: left, y: y, width: width, height: 18),
                    withAttributes: headingAttributes
                )
                y += 22

                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                paragraphStyle.lineSpacing = 3

                let noteAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .paragraphStyle: paragraphStyle
                ]

                NSString(string: note).draw(
                    in: CGRect(x: left, y: y, width: width, height: pageRect.height - y - 60),
                    withAttributes: noteAttributes
                )
            }
            return url
        } catch {
            return nil
        }
    }

    private func prepareShare(format: ExportFormat) {
        shareFormat = format
        switch format {
        case .pdf:
            shareURL = makeTemporaryPDFFile()
        case .text:
            shareURL = makeTemporaryTextFile()
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                headerSection

                noteCard

                VStack(alignment: .leading, spacing: 8) {
                    Text("Export")
                        .font(.headline)

                    HStack(spacing: 8) {
                        Button {
                            prepareShare(format: .pdf)
                        } label: {
                            Label("Create PDF", systemImage: "doc.richtext")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            prepareShare(format: .text)
                        } label: {
                            Label("Create TXT", systemImage: "doc.plaintext")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    if let shareURL {
                        ShareLink(item: shareURL) {
                            Label("Share \(shareFormat.rawValue)", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 22)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Caregiver Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
