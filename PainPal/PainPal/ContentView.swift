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

    var body: some View {
        TabView {
            NavigationStack {
                SessionsView()
            }
            .tabItem {
                Label("Sessions", systemImage: "list.bullet")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Recently Deleted", systemImage: "trash")
            }

            NavigationStack {
                ExportView()
            }
            .tabItem {
                Label("Export", systemImage: "square.and.arrow.up")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
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

// MARK: - Placeholder tabs (replace with real views later)

//#Preview("ContentView") {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Session.self, PainEntry.self, configurations: config)
//    let ctx = container.mainContext
//
//    // Ensure preview always shows sample data
//    UserDefaults.standard.set(false, forKey: "didSeedExampleData")
//
//    let amy = Session(childName: "Amy")
//    let ben = Session(childName: "Ben")
//
//    // Show one item in Recently Deleted
//    ben.isDeleted = true
//    ben.deletedAt = Date()
//
//    let e1 = PainEntry(scale: .wongBaker, score: 6, notes: "Crying after meal", transcript: nil, aiSummary: nil)
//    let e2 = PainEntry(scale: .rFLACC, score: 4, notes: "Settled after rest", transcript: nil, aiSummary: nil)
//
//    let _ = {
//        ctx.insert(amy)
//        ctx.insert(ben)
//        ctx.insert(e1)
//        ctx.insert(e2)
//        amy.entries.append(contentsOf: [e1, e2])
//    }()
//
//    return ContentView()
//        .modelContainer(container)
//}
