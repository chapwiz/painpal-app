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
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
    @State private var hasDateOfBirth: Bool = false

    // Quick record from Sessions tab
    @State private var recordingSession: Session? = nil

    @State private var searchText: String = ""

    @State private var isEditing: Bool = false
    @State private var selection = Set<PersistentIdentifier>()
    // Animates the appearance/disappearance of the selection UI (checkmarks + tap catcher)
    // without asking the whole List to animate (which causes ghosting).
    @State private var showSelectionUI: Bool = false

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


    var body: some View {
        content
    }

    // MARK: - View Composition

    private var content: some View {
        sessionsList
            .listStyle(.insetGrouped)
            .navigationTitle("PainPal")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingNew) {
                newSessionSheet
            }
            .onChange(of: isEditing) { _, newValue in
                if !newValue {
                    selection.removeAll()
                    showSelectionUI = false
                }
            }
    }

    @ViewBuilder
    private var sessionsList: some View {
        List {
            if displayedSessions.isEmpty {
                ContentUnavailableView(
                    searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No sessions yet" : "No matches",
                    systemImage: "list.bullet",
                    description: Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Tap New to start." : "Try a different name.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(displayedSessions) { s in
                    sessionRow(s)
                }
                // Only allow built-in swipe-to-delete outside our custom edit mode.
                .onDelete { indexSet in
                    guard !isEditing else { return }
                    for i in indexSet {
                        displayedSessions[i].softDelete()
                    }
                }
                .deleteDisabled(isEditing)
            }
        }
        // Avoid animating the entire List when toggling edit mode (prevents ghosting).
        // We animate the checkmark control explicitly inside the row instead.
        .animation(.easeInOut(duration: 0.18), value: showSelectionUI)
        .animation(.snappy, value: selection)
    }

    @ViewBuilder
    private func sessionRow(_ s: Session) -> some View {
        let sid = s.persistentModelID
        let isSelected = selection.contains(sid)

        // Shared row content so the list row identity stays stable across mode changes.
        let rowContent = HStack(spacing: 12) {
            if showSelectionUI {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.snappy, value: isSelected)
            }

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

        NavigationLink {
            SessionDetailView(session: s)
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
        // Allow normal navigation taps when not editing; when editing, the overlay captures taps.
        .allowsHitTesting(!(isEditing || showSelectionUI))
        // When editing, capture taps for selection without competing with NavigationLink.
        .overlay {
            if showSelectionUI {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isSelected {
                            selection.remove(sid)
                        } else {
                            selection.insert(sid)
                        }
                    }
            }
        }
        .contentShape(Rectangle())
        // Long press should not block normal taps; use simultaneous gesture.
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.35)
                .onEnded { _ in
                    // Press-and-hold enters edit mode and selects the pressed session.
                    guard !isEditing && !showSelectionUI else { return }
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isEditing = true
                        showSelectionUI = true
                    }
                    selection = [sid]
                }
        )
        // Only show swipe actions when not editing.
        .swipeActions(edge: .leading) {
            if !isEditing {
                Button {
                    recordingSession = s
                } label: {
                    Label("Record", systemImage: "plus")
                }
                .tint(.blue)
            }
        }
        .swipeActions(edge: .trailing) {
            if !isEditing {
                Button(role: .destructive) {
                    s.softDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }


    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if isEditing {
                Button("Done") {
                    // Animate selection UI out, then exit edit mode.
                    withAnimation(.easeInOut(duration: 0.18)) {
                        showSelectionUI = false
                        isEditing = false
                    }
                    selection.removeAll()
                }
            }
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
                    withAnimation(.easeInOut(duration: 0.18)) {
                        let selectedIDs = selection
                        for s in sessions where selectedIDs.contains(s.persistentModelID) {
                            s.softDelete()
                        }
                        selection.removeAll()
                        showSelectionUI = false
                        isEditing = false
                    }
                    try? ctx.save()
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete selected sessions")
            } else {
                Button {
                    showingNew = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Session")

                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(SortOption.allCases) { opt in
                            Text(opt.title).tag(opt)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
    }

    private var newSessionSheet: some View {
        NavigationStack {
            Form {
                Section("Child") {
                    TextField("Child name", text: $childName)
                        .textInputAutocapitalization(.words)

                    Toggle("Add date of birth", isOn: $hasDateOfBirth)

                    if hasDateOfBirth {
                        DatePicker(
                            "Date of birth",
                            selection: $dateOfBirth,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)

                        // Live preview of computed age
                        if let age = Session.ageString(for: dateOfBirth) {
                            Text("Age: \(age)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingNew = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trimmed = childName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        let dob: Date? = hasDateOfBirth ? dateOfBirth : nil
                        ctx.insert(Session(childName: trimmed, dateOfBirth: dob))
                        childName = ""
                        hasDateOfBirth = false
                        dateOfBirth = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
                        showingNew = false
                    }
                    .disabled(childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview("SessionsView — In-Memory") {
    // In-memory SwiftData container for previews (does not persist).
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, PainEntry.self, configurations: config)

    // Seed a few sessions so the list renders immediately.
    let ctx = container.mainContext
    ctx.insert(Session(childName: "Amy Chan"))
    ctx.insert(Session(childName: "Ben Wong"))
    ctx.insert(Session(childName: "Chloe Lee"))

    return NavigationStack {
        SessionsView()
    }
    .modelContainer(container)
}
