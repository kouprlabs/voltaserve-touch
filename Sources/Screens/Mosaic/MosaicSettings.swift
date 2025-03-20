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

public struct MosaicSettings: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ErrorPresentable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var mosaicStore = MosaicStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isCreating = false
    @State private var isDeleting = false
    private let file: VOFile.Entity

    public init(_ file: VOFile.Entity) {
        self.file = file
    }

    public var body: some View {
        NavigationView {
            VStack {
                if let snapshot = file.snapshot, snapshot.capabilities.mosaic {
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
                            .strokeBorder(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
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
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private var canCreate: Bool {
        !(file.snapshot?.task?.isPending ?? false) && file.permission.ge(.editor)
    }

    private var canDelete: Bool {
        !(file.snapshot?.task?.isPending ?? false) && file.permission.ge(.owner)
    }

    private var isProcesssing: Bool {
        isDeleting || isCreating
    }

    private func performCreate() {
        withErrorHandling {
            _ = try await mosaicStore.create()
            return true
        } before: {
            isCreating = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isCreating = false
        }
    }

    private func performDelete() {
        withErrorHandling {
            _ = try await mosaicStore.delete()
            return true
        } before: {
            isDeleting = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isDeleting = false
        }
    }

    // MARK: - LoadStateProvider

    public var isLoading: Bool {
        mosaicStore.metadataIsLoading
    }

    public var error: String? {
        mosaicStore.metadataError
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented: Bool = false
    @State public var errorMessage: String?

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        if let snapshot = file.snapshot, snapshot.capabilities.mosaic {
            mosaicStore.fetchMetadata()
        }
    }

    // MARK: - TimerLifecycle

    public func startTimers() {
        mosaicStore.startTimer()
    }

    public func stopTimers() {
        mosaicStore.stopTimer()
    }

    // MARK: - TokenDistributing

    public func assignTokenToStores(_ token: VOToken.Value) {
        mosaicStore.token = token
    }
}
