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

struct FileDelete: View {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var errorIsPresented = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    var body: some View {
        VStack {
            if isProcessing, !errorIsPresented {
                VOSheetProgressView()
                Text("Deleting \(fileStore.selection.count) item(s).")
            } else if errorIsPresented, errorSeverity == .full {
                VOErrorIcon()
                if let errorMessage {
                    Text(errorMessage)
                }
                Button {
                    dismiss()
                } label: {
                    VOButtonLabel("Done")
                }
                .voSecondaryButton(colorScheme: colorScheme)
                .padding(.horizontal)
            } else if errorIsPresented, errorSeverity == .partial {
                VOWarningIcon()
                if let errorMessage {
                    Text(errorMessage)
                }
                Button {
                    dismiss()
                } label: {
                    VOButtonLabel("Done")
                }
                .voSecondaryButton(colorScheme: colorScheme)
                .padding(.horizontal)
            }
        }
        .onAppear {
            performDelete()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performDelete() {
        var result: VOFile.DeleteResult?
        withErrorHandling(delaySeconds: 1) {
            result = try await fileStore.delete(Array(fileStore.selection))
            if let result {
                reflectDeleteInStore(result)
                if result.failed.isEmpty {
                    return true
                } else {
                    errorMessage = "Failed to delete \(result.failed.count) item(s)."
                    if result.failed.count < fileStore.selection.count {
                        errorSeverity = .partial
                    } else if result.failed.count == fileStore.selection.count {
                        errorSeverity = .full
                    }
                    errorIsPresented = true
                }
            }
            return false
        } success: {
            errorIsPresented = false
            dismiss()
        } failure: { _ in
            errorMessage = "Failed to delete \(fileStore.selection.count) item(s)."
            errorSeverity = .full
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }

    private func reflectDeleteInStore(_ result: VOFile.DeleteResult) {
        fileStore.entities?.removeAll(where: { entity in
            result.succeeded.contains(where: { entity.id == $0 })
        })
    }

    private enum ErrorSeverity {
        case full
        case partial
    }
}
