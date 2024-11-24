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

struct InsightsSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var insightsStore = InsightsStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isPatching = false
    @State private var isDeleting = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            VStack {
                if insightsStore.info != nil {
                    VStack(spacing: VOMetrics.spacingLg) {
                        VStack {
                            VStack {
                                Text("Collect insights for the active snapshot.")
                                Button {
                                    performPatch()
                                } label: {
                                    VOButtonLabel("Collect Insights", systemImage: "bolt", isLoading: isPatching)
                                }
                                .voSecondaryButton(colorScheme: colorScheme, isDisabled: isProcessing || !canCreate)
                            }
                            .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: VOMetrics.borderRadius)
                                .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
                        }
                        VStack {
                            VStack {
                                Text("Delete insights from the active snapshot.")
                                Button {
                                    performDelete()
                                } label: {
                                    VOButtonLabel("Delete Insights", systemImage: "trash", isLoading: isDeleting)
                                }
                                .voButton(color: .red400, isDisabled: isProcessing || !canDelete)
                            }
                            .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: VOMetrics.borderRadius)
                                .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                } else {
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: insightsStore.errorTitle,
            message: insightsStore.errorMessage
        )
        .onAppear {
            insightsStore.fileID = file.id
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
        .sync($insightsStore.showError, with: $showError)
    }

    private var canCreate: Bool {
        if let info = insightsStore.info {
            return !(file.snapshot?.task?.isPending ?? false) && info.isOutdated && file.permission.ge(.editor)
        }
        return false
    }

    private var canDelete: Bool {
        if let info = insightsStore.info {
            return !(file.snapshot?.task?.isPending ?? false) && !info.isOutdated && file.permission.ge(.owner)
        }
        return false
    }

    private var isProcessing: Bool {
        isDeleting || isPatching
    }

    private func performPatch() {
        isPatching = true
        withErrorHandling {
            _ = try await insightsStore.patch()
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Patching Insights"
            errorMessage = message
            showError = true
        } anyways: {
            isPatching = false
        }
    }

    private func performDelete() {
        isDeleting = true
        withErrorHandling {
            _ = try await insightsStore.delete()
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Deleting Insights"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        if let snapshot = file.snapshot, snapshot.hasEntities() {
            insightsStore.fetchInfo()
        }
    }

    private func startTimers() {
        insightsStore.startTimer()
    }

    private func stopTimers() {
        insightsStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        insightsStore.token = token
    }
}
