// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import AuthenticationServices
import SwiftUI

public struct SignInWithApple: View, ErrorPresentable {
    @EnvironmentObject private var tokenStore: TokenStore
    @State private var isProcessing = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signUpIsPresented = false
    @State private var forgotPasswordIsPresented = false
    @Environment(\.colorScheme) private var colorScheme
    private let onCompletion: (() -> Void)?

    public init(_ onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: VOMetrics.spacingXl) {
                VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
                                let identityTokenData = credential.identityToken,
                                let identityToken = String(data: identityTokenData, encoding: .utf8)
                            {
                                Task {
                                    await performSignIn(
                                        identityToken,
                                        fullName: [credential.fullName?.givenName, credential.fullName?.familyName]
                                            .compactMap { $0 }
                                            .joined(separator: " ")
                                    )
                                }
                            } else {
                                errorMessage = "Failed to parse Apple credentials."
                                errorIsPresented = true
                            }
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            errorIsPresented = true
                        }
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(width: VOMetrics.formWidth, height: VOButtonMetrics.height)
                .clipShape(RoundedRectangle(cornerRadius: VOButtonMetrics.height / 2))
                .disabled(isProcessing)
            }
            .padding()
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performSignIn(_ jwt: String, fullName: String?) async {
        var token: VOToken.Value?
        withErrorHandling {
            token = try await tokenStore.signInWithApple(jwt: jwt, fullName: fullName)
            return true
        } before: {
            isProcessing = true
        } success: {
            if let token {
                tokenStore.token = token
                tokenStore.saveInKeychain(token)
                onCompletion?()
            }
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented = false
    @State public var errorMessage: String?
}

#Preview {
    SignInWithApple()
}
