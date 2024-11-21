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

struct MosaicSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var mosaicStore = MosaicStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isCreating = false
    @State private var isDeleting = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            VStack {
                if mosaicStore.info != nil {
                    VStack(spacing: VOMetrics.spacingLg) {
                        VStack {
                            VStack {
                                Text("Create a mosaic for the active snapshot.")
                                Button {
                                    performCreate()
                                } label: {
                                    VOButtonLabel("Create Mosaic", systemImage: "bolt", isLoading: isCreating)
                                }
                                .voSecondaryButton(colorScheme: colorScheme, isDisabled: isProcesssing || !canCreate)
                            }
                            .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: VOMetrics.borderRadius)
                                .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
                        }
                        VStack {
                            VStack {
                                Text("Delete mosaic from the active snapshot.")
                                Button {
                                    performDelete()
                                } label: {
                                    VOButtonLabel("Delete Mosaic", systemImage: "trash", isLoading: isDeleting)
                                        .foregroundStyle(Color.red400.textColor())
                                }
                                .voButton(color: .red400, isDisabled: isProcesssing || !canDelete)
                            }
                            .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: VOMetrics.borderRadius)
                                .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
                        }
                    }
                    .padding(.horizontal)
                    .modifierIfPad {
                        $0.padding(.bottom)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Mosaic")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(isProcesssing)
                }
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: mosaicStore.errorTitle,
            message: mosaicStore.errorMessage
        )
        .onAppear {
            mosaicStore.fileID = file.id
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
        .presentationDetents([.fraction(UIDevice.current.userInterfaceIdiom == .pad ? 0.50 : 0.40)])
        .sync($mosaicStore.showError, with: $showError)
    }

    private var canCreate: Bool {
        if let info = mosaicStore.info {
            return !(file.snapshot?.task?.isPending ?? false) &&
                info.isOutdated &&
                file.permission.ge(.editor)
        }
        return false
    }

    private var canDelete: Bool {
        if let info = mosaicStore.info {
            return !(file.snapshot?.task?.isPending ?? false) &&
                !info.isOutdated &&
                file.permission.ge(.owner)
        }
        return false
    }

    private var isProcesssing: Bool {
        isDeleting || isCreating
    }

    private func performCreate() {
        isCreating = true
        withErrorHandling {
            _ = try await mosaicStore.create()
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Creating Mosaic"
            errorMessage = message
            showError = true
        } anyways: {
            isCreating = false
        }
    }

    private func performDelete() {
        isDeleting = true
        withErrorHandling {
            _ = try await mosaicStore.delete()
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Deleting Mosaic"
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
        if let snapshot = file.snapshot, snapshot.hasMosaic() {
            mosaicStore.fetchInfo()
        }
    }

    private func startTimers() {
        mosaicStore.startTimer()
    }

    private func stopTimers() {
        mosaicStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        mosaicStore.token = token
    }
}
