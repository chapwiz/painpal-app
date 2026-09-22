//
//  ContentView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var ctx
    @AppStorage("didSeedExampleData") private var didSeedExampleData = false
    @AppStorage("userRole") private var userRoleRawValue = ""
    @State private var selectedTab: RootTab = .sessions
    @State private var searchString = ""

    var body: some View {
        AuthGateView()
            .task {
                // Avoid double-seeding when running SwiftUI previews
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return }

                // Count all sessions + non-deleted sessions
                let totalSessions = (try? ctx.fetchCount(FetchDescriptor<Session>())) ?? 0
                let activeSessions = (try? ctx.fetchCount(FetchDescriptor<Session>(
                    predicate: #Predicate<Session> { !$0.isDeleted }
                ))) ?? 0

                // If you already have at least 20 sessions, don’t seed.
                if totalSessions >= 20 {
                    didSeedExampleData = true
                    return
                }

                // If you already have any active sessions, don’t seed.
                if activeSessions > 0 {
                    didSeedExampleData = true
                    return
                }

                // Otherwise, seed (covers the case where you only have deleted sessions, or none at all)
                seedExampleData()
                didSeedExampleData = true
            }
    }

    @ViewBuilder
    private func mainTabView(for role: UserRole) -> some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .sessions) {
                NavigationStack {
                    switch role {
                    case .parent:
                        ParentHomeView()
                    case .caregiver:
                        SessionsView()
                    }
                }
            }

            if role == .caregiver {
                Tab(value: .search, role: .search) {
                    NavigationStack {
                        SessionSearchView(searchString: $searchString)
                    }
                }
            }

            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .task {
            // Avoid double-seeding when running SwiftUI previews
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return }

            // Count all sessions + non-deleted sessions
            let totalSessions = (try? ctx.fetchCount(FetchDescriptor<Session>())) ?? 0
            let activeSessions = (try? ctx.fetchCount(FetchDescriptor<Session>(
                predicate: #Predicate<Session> { !$0.isDeleted }
            ))) ?? 0

            // If you already have at least 20 sessions, don’t seed.
            if totalSessions >= 20 {
                didSeedExampleData = true
                return
            }

            // If you already have any active sessions, don’t seed.
            if activeSessions > 0 {
                didSeedExampleData = true
                return
            }

            // Otherwise, seed (covers the case where you only have deleted sessions, or none at all)
            seedExampleData()
            didSeedExampleData = true
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

enum RootTab: Hashable {
    case sessions
    case search
    case settings
}

private struct SessionSearchView: View {
    @Binding var searchString: String

    @Query(
        filter: #Predicate<Session> { !$0.isDeleted },
        sort: [SortDescriptor(\Session.createdAt, order: .reverse)]
    ) private var sessions: [Session]

    private var filteredSessions: [Session] {
        let trimmed = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return sessions }
        return sessions.filter {
            $0.childName.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        List {
            if filteredSessions.isEmpty {
                ContentUnavailableView(
                    "No matching sessions",
                    systemImage: "magnifyingglass",
                    description: Text(searchString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? "Start typing to search by child name."
                        : "Try a different name.")
                )
            } else {
                ForEach(filteredSessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.childName)
                                .font(.headline)

                            Text(session.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchString, prompt: "Search sessions")
    }
}

enum DemoDataSeeder {
    static func seed(ctx: ModelContext, sessionCount: Int = 24) {
        let now = Date()

        // A realistic mix of common names (UK/US leaning) for testing
        let names: [String] = [
            "Amy", "Ben", "Chloe", "Daniel", "Ella", "Freddie", "Grace", "Harry",
            "Isla", "Jack", "Katie", "Leo", "Mia", "Noah", "Olivia", "Poppy",
            "Ruby", "Sam", "Sophie", "Theo", "William", "Zara", "Adam", "Emily",
            "Finley", "Hannah", "Joshua", "Lily", "Max", "Niamh", "Oscar", "Phoebe",
            "Rowan", "Sienna", "Thomas", "Violet"
        ]

        for i in 0..<max(sessionCount, 20) {
            let childName = names[i % names.count]

            // Stagger creation times to make sorting meaningful (every 6 hours)
            let createdAt = now.addingTimeInterval(-Double(i) * 60 * 60 * 6)

            // Put some into Recently Deleted (every 9th)
            let isDeleted = ((i + 1) % 9 == 0)
            let deletedAt = isDeleted ? now.addingTimeInterval(-Double(i) * 60 * 20) : nil

            let session = Session(
                childName: childName,
                createdAt: createdAt,
                isDeleted: isDeleted,
                deletedAt: deletedAt
            )

            // 0–5 entries each (deterministic pattern for repeatable UI testing)
            let entryCount = ((i + 3) * 37) % 6

            if entryCount > 0 {
                for j in 1...entryCount {
                    let scale: PainScale = (j % 2 == 0) ? .rFLACC : .wongBaker
                    let score = (i + j * 2) % 11

                    let entry = PainEntry(
                        scale: scale,
                        score: score,
                        notes: "Sample note \(j) for \(childName)",
                        transcript: nil,
                        aiSummary: nil
                    )

                    session.entries.append(entry)
                    ctx.insert(entry)
                }
            }

            ctx.insert(session)
        }
    }
}

extension ContentView {
    fileprivate func seedExampleData() {
        DemoDataSeeder.seed(ctx: ctx, sessionCount: 24)
    }
}
