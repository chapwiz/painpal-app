//
//  AppleSignInButtonView.swift
//  PainPal
//
//  Created by Chapman Leung on 26/3/2026.
//

import SwiftUI
import AuthenticationServices

struct AppleSignInButtonView: View {
    var onRequest: (ASAuthorizationAppleIDRequest) -> Void = { request in
        request.requestedScopes = [.fullName, .email]
    }

    var onCompletion: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                onRequest(request)
            },
            onCompletion: { result in
                onCompletion(result)
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityLabel("Sign in with Apple")
    }
}

#Preview {
    AppleSignInButtonView { _ in }
        .padding()
}
