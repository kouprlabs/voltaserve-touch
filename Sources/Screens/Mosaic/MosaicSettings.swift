import SwiftUI
import VoltaserveCore

struct MosaicSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var mosaicStore = MosaicStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError = false
    @State private var isCreating = false
    @State private var isDeleting = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationStack {
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
                mosaicStore.startTimer()
                onAppearOrChange()
            }
        }
        .onDisappear {
            mosaicStore.stopTimer()
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
            try await mosaicStore.create(file.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            mosaicStore.errorTitle = "Error: Creating Mosaic"
            mosaicStore.errorMessage = message
            showError = true
        } anyways: {
            isCreating = false
        }
    }

    private func performDelete() {
        isDeleting = true
        withErrorHandling {
            try await mosaicStore.delete(file.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            mosaicStore.errorTitle = "Error: Deleting Mosaic"
            mosaicStore.errorMessage = message
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

    private func assignTokenToStores(_ token: VOToken.Value) {
        mosaicStore.token = token
    }
}
