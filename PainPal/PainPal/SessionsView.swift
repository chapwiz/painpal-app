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
    @Query(filter: #Predicate<PainEntry> { !$0.isDeleted }) private var activePainEntries: [PainEntry]
    
    @State private var showingNew = false
    @State private var childName = ""
    
    // Quick record from Sessions tab
    @State private var recordingSession: Session? = nil
    
    @State private var searchText: String = ""

    @Environment(\.editMode) private var editMode
    @State private var selection = Set<PersistentIdentifier>()

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
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
                let a = activeEntryCount(for: $0)
                let b = activeEntryCount(for: $1)
                if a != b { return a > b }
                return $0.createdAt > $1.createdAt
            case .leastEntries:
                let a = activeEntryCount(for: $0)
                let b = activeEntryCount(for: $1)
                if a != b { return a < b }
                return $0.createdAt > $1.createdAt
            }
        }
        
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        return base.filter { $0.childName.localizedCaseInsensitiveContains(q) }
    }
    
    private var activeEntryCountBySessionID: [PersistentIdentifier: Int] {
        var dict: [PersistentIdentifier: Int] = [:]
        for e in activePainEntries {
            if let sid = e.session?.persistentModelID {
                dict[sid, default: 0] += 1
            }
        }
        return dict
    }

    private func activeEntryCount(for session: Session) -> Int {
        activeEntryCountBySessionID[session.persistentModelID] ?? 0
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
        content
    }
    
    // MARK: - View Composition

    private var content: some View {
        sessionsList
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .safeAreaInset(edge: .bottom) {
                floatingNewSessionBar
            }
            .navigationTitle("Sessions")
            .toolbar {
                toolbarContent
            }
            .onChange(of: isEditing) { _, newValue in
                if !newValue { selection.removeAll() }
            }
            .sheet(isPresented: $showingNew) {
                newSessionSheet
            }
            .sheet(item: $recordingSession) { s in
                NavigationStack {
                    RecordEntryView(session: s)
                }
            }
    }

    @ViewBuilder
    private var sessionsList: some View {
        List(selection: $selection) {
            if displayedSessions.isEmpty {
                ContentUnavailableView(
                    searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No sessions yet" : "No matches",
                    systemImage: "list.bullet",
                    description: Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Tap New Session to start." : "Try a different name.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(displayedSessions) { s in
                    sessionRow(s)
                        .tag(s.persistentModelID)
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        displayedSessions[i].softDelete()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sessionRow(_ s: Session) -> some View {
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

                let count = activeEntryCount(for: s)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .accessibilityLabel("\(count) entr\(count == 1 ? "y" : "ies")")
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

    private var floatingNewSessionBar: some View {
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
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            EditButton()
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            if isEditing {
                Button("Select All") {
                    selection = Set(displayedSessions.map { $0.persistentModelID })
                }

                Button("Clear") {
                    selection.removeAll()
                }

                Button(role: .destructive) {
                    let selectedIDs = selection
                    for s in sessions where selectedIDs.contains(s.persistentModelID) {
                        s.softDelete()
                    }
                    selection.removeAll()
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete selected sessions")
            } else {
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
        }
    }

    private var newSessionSheet: some View {
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
}
