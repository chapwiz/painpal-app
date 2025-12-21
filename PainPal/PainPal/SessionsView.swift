//
//  SessionsView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData

struct SessionsView: View {
    @Environment(\.modelContext) private var ctx
    @Query(filter: #Predicate<Session> { !$0.isDeleted }) private var sessions: [Session]

    @State private var showingNew = false
    @State private var childName = ""

    // Quick record from Sessions tab
    @State private var recordingSession: Session? = nil

    @State private var searchText: String = ""

    enum SortOption: String, CaseIterable, Identifiable {
        case newest
        case oldest
        case mostEntries
        case leastEntries

        var id: String { rawValue }

        var title: String {
            switch self {
            case .newest: return "Newest"
            case .oldest: return "Oldest"
            case .mostEntries: return "Most entries"
            case .leastEntries: return "Least entries"
            }
        }
    }

    @State private var sort: SortOption = .newest

    private var displayedSessions: [Session] {
        let base = sessions.sorted {
            switch sort {
            case .newest:
                return $0.createdAt > $1.createdAt
            case .oldest:
                return $0.createdAt < $1.createdAt
            case .mostEntries:
                if $0.entries.count != $1.entries.count {
                    return $0.entries.count > $1.entries.count
                }
                return $0.createdAt > $1.createdAt
            case .leastEntries:
                if $0.entries.count != $1.entries.count {
                    return $0.entries.count < $1.entries.count
                }
                return $0.createdAt > $1.createdAt
            }
        }

        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        return base.filter { $0.childName.localizedCaseInsensitiveContains(q) }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(whereSeparator: { $0 == " " || $0 == "-" })
        let letters = parts.prefix(2).compactMap { $0.first }.map { String($0).uppercased() }
        return letters.joined()
    }

    private struct FloatingPillButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundStyle(.primary)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(.separator, lineWidth: 1)
                }
                .shadow(
                    radius: configuration.isPressed ? 4 : 10,
                    y: configuration.isPressed ? 2 : 5
                )
                .scaleEffect(configuration.isPressed ? 0.96 : 1)
                .opacity(configuration.isPressed ? 0.98 : 1)
                .animation(
                    .interactiveSpring(response: 0.28, dampingFraction: 0.4, blendDuration: 0.25),
                    value: configuration.isPressed
                )
        }
    }

    var body: some View {
        List {
            if displayedSessions.isEmpty {
                ContentUnavailableView(
                    searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No sessions yet" : "No matches",
                    systemImage: "list.bullet",
                    description: Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Tap New Session to start." : "Try a different name.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(displayedSessions) { s in
                    NavigationLink {
                        SessionDetailView(session: s)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.thinMaterial)
                                    .frame(width: 40, height: 40)
                                Text(initials(for: s.childName))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(s.childName)
                                    .font(.headline)

                                Text(s.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(s.entries.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                                .accessibilityLabel("\(s.entries.count) entr\(s.entries.count == 1 ? "y" : "ies")")
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            recordingSession = s
                        } label: {
                            Label("Record", systemImage: "plus")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            s.softDelete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        displayedSessions[i].softDelete()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        // Floating action button area above the tab bar
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    showingNew = true
                } label: {
                    Label("New Session", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FloatingPillButtonStyle())
                // slightly narrower than full width, visually aligned with the tab bar
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .navigationTitle("Sessions")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(SortOption.allCases) { opt in
                            Text(opt.title).tag(opt)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
        }
        .sheet(isPresented: $showingNew) {
            NavigationStack {
                Form {
                    TextField("Child name", text: $childName)
                        .textInputAutocapitalization(.words)
                }
                .navigationTitle("New Session")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingNew = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            let trimmed = childName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            ctx.insert(Session(childName: trimmed))
                            childName = ""
                            showingNew = false
                        }
                        .disabled(childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .sheet(item: $recordingSession) { s in
            NavigationStack {
                RecordEntryView(session: s)
            }
        }
    }
}

#Preview("SessionsView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, PainEntry.self, configurations: config)
    let ctx = container.mainContext

    let _ = {
        ctx.insert(Session(childName: "Amy"))
        ctx.insert(Session(childName: "Ben"))
    }()

    return NavigationStack {
        SessionsView()
    }
    .modelContainer(container)
}
