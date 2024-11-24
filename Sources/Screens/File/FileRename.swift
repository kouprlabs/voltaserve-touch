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
import VoltaserveCore

struct FileRename: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing, FormValidatable,
    ErrorPresentable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var fileStore = FileStore()
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false
    @State private var value = ""
    private let file: VOFile.Entity
    private let onCompletion: ((VOFile.Entity) -> Void)?

    init(_ file: VOFile.Entity, onCompletion: ((VOFile.Entity) -> Void)? = nil) {
        self.file = file
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error {
                    VOErrorMessage(error)
                } else {
                    if !value.isEmpty {
                        Form {
                            TextField("Name", text: $value)
                                .disabled(isSaving)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Rename")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            performRename()
                        }
                        .disabled(!isValid())
                    }
                }
            }
            .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
            .onAppear {
                fileStore.file = file
                if let token = tokenStore.token {
                    assignTokenToStores(token)
                    startTimers()
                    onAppearOrChange()
                }
            }
            .onDisappear {
                stopTimers()
            }
            .onChange(of: tokenStore.token) { _, newToken in
                if let newToken {
                    assignTokenToStores(newToken)
                    onAppearOrChange()
                }
            }
            .onChange(of: fileStore.file) { _, file in
                if let file {
                    value = file.name
                }
            }
        }
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performRename() {
        guard let file = fileStore.file else { return }
        isSaving = true
        var updatedFile: VOFile.Entity?

        withErrorHandling {
            updatedFile = try await fileStore.patchName(file.id, name: normalizedValue)
            return true
        } success: {
            dismiss()
            if let onCompletion, let updatedFile {
                onCompletion(updatedFile)
            }
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isSaving = false
        }
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        fileStore.fileIsLoading
    }

    var error: String? {
        fileStore.fileError
    }

    // MARK: - ErrorPresentable

    @State var errorIsPresented: Bool = false
    @State var errorMessage: String?

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        fileStore.fetchFile()
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        fileStore.startTimer()
    }

    func stopTimers() {
        fileStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }

    // MARK: - FormValidatable

    func isValid() -> Bool {
        if let file = fileStore.file {
            return !normalizedValue.isEmpty && normalizedValue != file.name
        }
        return false
    }
}
