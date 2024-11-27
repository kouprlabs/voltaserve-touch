// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI

struct ForgotPassword: View, FormValidatable, ErrorPresentable {
    @StateObject private var forgotPasswordStore = ForgotPasswordStore()
    @State private var email: String = ""
    @State private var isProcessing: Bool = false
    private let onCompletion: (() -> Void)?
    private let onSignIn: (() -> Void)?

    init(_ onCompletion: (() -> Void)? = nil, onSignIn: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
        self.onSignIn = onSignIn
    }

    var body: some View {
        NavigationView {
            VStack(spacing: VOMetrics.spacing) {
                VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
                Text("Forgot Password")
                    .voHeading(fontSize: VOMetrics.headingFontSize)
                Text("Please provide your account Email where we can send you the password recovery instructions.")
                    .voFormHintText()
                    .frame(width: VOMetrics.formWidth)
                    .multilineTextAlignment(.center)
                TextField("Email", text: $email)
                    .voTextField(width: VOMetrics.formWidth)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isProcessing)
                Button {
                    if isValid() {
                        performSendResetPasswordEmail()
                    }
                } label: {
                    VOButtonLabel(
                        "Send Recovery Instructions",
                        isLoading: isProcessing,
                        progressViewTint: .white
                    )
                }
                .voPrimaryButton(width: VOMetrics.formWidth, isDisabled: isProcessing)
                HStack {
                    Text("Password recovered?")
                        .voFormHintText()
                    Button {
                        onSignIn?()
                    } label: {
                        Text("Sign In")
                            .voFormHintLabel()
                    }
                    .disabled(isProcessing)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSignIn?()
                    } label: {
                        Text("Back to Sign In")
                    }
                }
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }
    
    private func performSendResetPasswordEmail() {
        withErrorHandling {
            _ = try await forgotPasswordStore.sendResetPasswordEmail(.init(email: email))
            return true
        } before: {
            isProcessing = true
        } success: {
            onCompletion?()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }
    
    // MARK: - ErrorPresentable
    
    @State var errorIsPresented: Bool = false
    @State var errorMessage: String?
    
    // MARK: - FormValidatable

    func isValid() -> Bool {
        !email.isEmpty
    }
}

#Preview {
    ForgotPassword()
}
