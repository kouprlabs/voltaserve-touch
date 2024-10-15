import SwiftUI
import VoltaserveCore

struct MosaicCreate: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var mosaicStore = MosaicStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isCreating = false
    private let fileID: String

    init(_ fileID: String) {
        self.fileID = fileID
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    ScrollView {
                        // swiftlint:disable:next line_length
                        Text("Create a mosaic to enhance view performance of a large image by splitting it into smaller, manageable tiles. This makes browsing a high-resolution image faster and more efficient.")
                    }
                    Button {
                        performCreate()
                    } label: {
                        VOButtonLabel("Create Mosaic", isLoading: isCreating)
                    }
                    .voPrimaryButton(isDisabled: isCreating)
                }
                .padding()
            }
            .overlay {
                RoundedRectangle(cornerRadius: VOMetrics.borderRadius)
                    .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
            }
            .padding(.horizontal)
            .modifierIfPad {
                $0.padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Mosaic")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(isCreating)
                }
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: mosaicStore.errorTitle,
            message: mosaicStore.errorMessage
        )
        .onAppear {
            mosaicStore.fileID = fileID
            if let token = tokenStore.token {
                assignTokenToStores(token)
            }
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
        .presentationDetents([.fraction(0.35)])
        .sync($mosaicStore.showError, with: $showError)
    }

    private func performCreate() {
        isCreating = true
        withErrorHandling {
            try await mosaicStore.create()
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

    private func assignTokenToStores(_ token: VOToken.Value) {
        mosaicStore.token = token
    }
}
