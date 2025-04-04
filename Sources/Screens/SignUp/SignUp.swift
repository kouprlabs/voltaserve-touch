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

public struct SignUp: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, FormValidatable {
    @StateObject private var signUpStore = SignUpStore()
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isProcessing = false
    private let onCompletion: (() -> Void)?
    private let onSignIn: (() -> Void)?

    public init(_ onCompletion: (() -> Void)? = nil, onSignIn: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
        self.onSignIn = onSignIn
    }

    public var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error {
                    VOErrorMessage(error)
                } else {
                    if let passwordRequirements = signUpStore.passwordRequirements {
                        VStack(spacing: VOMetrics.spacingXl) {
                            VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
                            TextField("Full name", text: $fullName)
                                .voTextField(width: VOMetrics.formWidth)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .disabled(isProcessing)
                            TextField("Email", text: $email)
                                .voTextField(width: VOMetrics.formWidth)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .disabled(isProcessing)
                            SecureField("Password", text: $password)
                                .voTextField(width: VOMetrics.formWidth)
                                .disabled(isProcessing)
                            VStack(alignment: .listRowSeparatorLeading) {
                                SignUpPasswordHint(
                                    "\(passwordRequirements.minLength) characters.",
                                    isFulfilled: password.hasMinLength(passwordRequirements.minLength))
                                SignUpPasswordHint(
                                    "\(passwordRequirements.minLowercase) lowercase character.",
                                    isFulfilled: password.hasMinLowerCase(passwordRequirements.minLowercase))
                                SignUpPasswordHint(
                                    "\(passwordRequirements.minUppercase) uppercase character.",
                                    isFulfilled: password.hasMinUpperCase(passwordRequirements.minUppercase))
                                SignUpPasswordHint(
                                    "\(passwordRequirements.minNumbers) number.",
                                    isFulfilled: password.hasMinNumbers(passwordRequirements.minNumbers))
                                SignUpPasswordHint(
                                    "\(passwordRequirements.minSymbols) special character(s) (!#$%).",
                                    isFulfilled: password.hasMinSymbols(passwordRequirements.minSymbols))
                                SignUpPasswordHint(
                                    "Passwords match.",
                                    isFulfilled: !password.isEmpty && !confirmPassword.isEmpty
                                        && password == confirmPassword)
                            }
                            .frame(width: VOMetrics.formWidth)
                            SecureField("Confirm password", text: $confirmPassword)
                                .voTextField(width: VOMetrics.formWidth)
                                .disabled(isProcessing)
                            Button {
                                if isValid() {
                                    performSignUp()
                                }
                            } label: {
                                VOButtonLabel(
                                    "Sign Up",
                                    isLoading: isProcessing,
                                    progressViewTint: .white
                                )
                            }
                            .voPrimaryButton(width: VOMetrics.formWidth, isDisabled: isProcessing)
                            HStack {
                                Text("Already a member?")
                                    .voFormHintText()
                                Button {
                                    onSignIn?()
                                } label: {
                                    Text("Sign in")
                                        .voFormHintLabel()
                                }
                                .disabled(isProcessing)
                            }
                        }

                    }
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
        .onAppear {
            startTimers()
            onAppearOrChange()
        }
        .onDisappear {
            stopTimers()
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performSignUp() {
        withErrorHandling {
            _ = try await signUpStore.signUp(.init(email: email, password: password, fullName: fullName))
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

    @State public var errorIsPresented = false
    @State public var errorMessage: String?

    // MARK: - ViewDataProvider

    public var isLoading: Bool {
        signUpStore.passwordRequirementsIsLoading
    }

    public var error: String? {
        signUpStore.passwordRequirementsError
    }

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        signUpStore.fetchPasswordRequirements()
    }

    // MARK: - TimerLifecycle

    public func startTimers() {
        signUpStore.startTimer()
    }

    public func stopTimers() {
        signUpStore.stopTimer()
    }

    // MARK: - FormValidatable

    public func isValid() -> Bool {
        !email.isEmpty && !fullName.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
            && password == confirmPassword
    }
}

#Preview {
    SignUp()
}
