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

struct ForgotPassword: View {
    @State private var isLoading = false
    @State private var email: String = ""
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
                Text(
                    "Please provide your account Email where we can send you the password recovery instructions."
                )
                .voFormHintText()
                .frame(width: VOMetrics.formWidth)
                .multilineTextAlignment(.center)
                TextField("Email", text: $email)
                    .voTextField(width: VOMetrics.formWidth)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isLoading)
                Button {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isLoading = false
                        onCompletion?()
                    }
                } label: {
                    VOButtonLabel(
                        "Send Recovery Instructions",
                        isLoading: isLoading,
                        progressViewTint: .white
                    )
                }
                .voPrimaryButton(width: VOMetrics.formWidth, isDisabled: isLoading)
                HStack {
                    Text("Password recovered?")
                        .voFormHintText()
                    Button {
                        onSignIn?()
                    } label: {
                        Text("Sign In")
                            .voFormHintLabel()
                    }
                    .disabled(isLoading)
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
    }
}

#Preview {
    ForgotPassword()
}
