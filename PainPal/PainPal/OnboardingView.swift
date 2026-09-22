//
//  OnboardingView.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("userRole") private var userRoleRawValue = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 10) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.pink)

                    Text("Welcome to PainPal")
                        .font(.largeTitle.bold())

                    Text("Choose how you’ll be using PainPal. You can change this later in Settings.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                VStack(spacing: 14) {
                    ForEach(UserRole.allCases) { role in
                        Button {
                            userRoleRawValue = role.rawValue
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: role.iconName)
                                    .font(.title2)
                                    .frame(width: 30)
                                    .foregroundStyle(Color.accentColor)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(role.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(role.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Text("This only affects the home experience and navigation style in the app.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
