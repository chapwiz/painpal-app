//
//  AuthGateView.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import SwiftUI

struct AuthGateView: View {
    @State private var authViewModel = AuthViewModel()
    @AppStorage("userRole") private var userRoleRawValue = ""

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                authenticatedContent
            } else {
                unauthenticatedContent
            }
        }
    }

    @ViewBuilder
    private var authenticatedContent: some View {
        if authViewModel.currentUser != nil {
            if userRoleRawValue.isEmpty {
                OnboardingView()
            } else {
                AuthenticatedRootView()
            }
        } else {
            unauthenticatedContent
        }
    }

    private var unauthenticatedContent: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.green.opacity(0.06)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    VStack(spacing: 14) {
                        Image("PainPal-Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

                        VStack(spacing: 8) {
                            Text("Welcome to PainPal")
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)

                            Text("Sign in with Apple to access your private records, child profiles, and personalised home experience.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 28)

                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Get started")
                                .font(.headline)

                            Text("Your role and home experience will be set up after sign-in.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        AppleSignInButtonView { result in
                            authViewModel.handleAppleSignIn(result: result)
                        }

                        if authViewModel.isLoading {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Signing in...")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let errorMessage = authViewModel.errorMessage, !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 20)

                    Spacer()

                    Text("Private by design for families and caregivers.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct AuthenticatedRootView: View {
    @AppStorage("userRole") private var userRoleRawValue = ""
    @State private var selectedTab: RootTab = .sessions

    private var currentRole: UserRole {
        UserRole(rawValue: userRoleRawValue) ?? .caregiver
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .sessions) {
                NavigationStack {
                    switch currentRole {
                    case .parent:
                        ParentHomeView()
                    case .caregiver:
                        SessionsView()
                    }
                }
            }

            if currentRole == .caregiver {
                Tab(value: .search, role: .search) {
                    NavigationStack {
                        SessionsView()
                    }
                }
            }

            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
