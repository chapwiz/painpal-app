//
//  AuthViewModel.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import Foundation
import AuthenticationServices
import Observation

@Observable
final class AuthViewModel {
    var isAuthenticated = false
    var currentUser: AuthenticatedUser?
    var isLoading = false
    var errorMessage: String?
    var latestApplePayload: AppleSignInPayload?

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil

        do {
            switch result {
            case .success(let authorization):
                let payload = try AuthService.shared.makeApplePayload(from: authorization)
                latestApplePayload = payload

                // Temporary local-only auth state until backend verification is wired in.
                let resolvedRole = UserRole(rawValue: UserDefaults.standard.string(forKey: "userRole") ?? "") ?? .caregiver
                currentUser = AuthenticatedUser(
                    id: payload.userIdentifier,
                    appleSubject: payload.userIdentifier,
                    email: payload.email,
                    role: resolvedRole
                )
                isAuthenticated = true

            case .failure(let error):
                errorMessage = error.localizedDescription
                isAuthenticated = false
                currentUser = nil
            }
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            currentUser = nil
        }

        isLoading = false
    }

    func logout() {
        isAuthenticated = false
        currentUser = nil
        latestApplePayload = nil
        errorMessage = nil
    }
}
