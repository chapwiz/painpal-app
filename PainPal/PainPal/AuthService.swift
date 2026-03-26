//
//  AuthService.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import Foundation
import AuthenticationServices

struct AppleSignInPayload: Codable {
    let userIdentifier: String
    let identityToken: String
    let authorizationCode: String
    let email: String?
    let givenName: String?
    let familyName: String?
}

enum AuthServiceError: LocalizedError {
    case invalidCredential
    case missingIdentityToken
    case invalidIdentityToken
    case missingAuthorizationCode
    case invalidAuthorizationCode

    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Unable to read the Apple sign-in credential."
        case .missingIdentityToken:
            return "The Apple sign-in response did not include an identity token."
        case .invalidIdentityToken:
            return "The identity token could not be converted to text."
        case .missingAuthorizationCode:
            return "The Apple sign-in response did not include an authorization code."
        case .invalidAuthorizationCode:
            return "The authorization code could not be converted to text."
        }
    }
}

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func makeApplePayload(from authorization: ASAuthorization) throws -> AppleSignInPayload {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthServiceError.invalidCredential
        }

        guard let identityTokenData = credential.identityToken else {
            throw AuthServiceError.missingIdentityToken
        }
        guard let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            throw AuthServiceError.invalidIdentityToken
        }

        guard let authorizationCodeData = credential.authorizationCode else {
            throw AuthServiceError.missingAuthorizationCode
        }
        guard let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
            throw AuthServiceError.invalidAuthorizationCode
        }

        return AppleSignInPayload(
            userIdentifier: credential.user,
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            email: credential.email,
            givenName: credential.fullName?.givenName,
            familyName: credential.fullName?.familyName
        )
    }
}
