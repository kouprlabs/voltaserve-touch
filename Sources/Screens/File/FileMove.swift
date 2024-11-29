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

struct FileMove: View {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var errorIsPresented = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?
    private let destinationID: String

    init(fileStore: FileStore, to destinationID: String) {
        self.fileStore = fileStore
        self.destinationID = destinationID
    }

    var body: some View {
        VStack {
            if isProcessing, !errorIsPresented {
                VOSheetProgressView()
                if fileStore.selection.count > 1 {
                    Text("Moving (\(fileStore.selection.count)) items.")
                } else {
                    Text("Moving item.")
                }
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
            performMove()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performMove() {
        var result: VOFile.MoveResult?
        withErrorHandling(delaySeconds: 1) {
            result = try await fileStore.move(Array(fileStore.selection), to: destinationID)
            if let result {
                reflectMoveInStore(result)
                if result.failed.isEmpty {
                    return true
                } else {
                    if result.failed.count > 1 {
                        errorMessage = "Failed to move (\(result.failed.count)) items."
                    } else {
                        errorMessage = "Failed to move item."
                    }
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
            if fileStore.selection.count > 1 {
                errorMessage = "Failed to move (\(fileStore.selection.count)) items."
            } else {
                errorMessage = "Failed to move item."
            }
            errorSeverity = .full
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }

    private func reflectMoveInStore(_ result: VOFile.MoveResult) {
        fileStore.entities?.removeAll(where: { entity in
            result.succeeded.contains(where: { entity.id == $0 })
        })
    }

    private enum ErrorSeverity {
        case full
        case partial
    }
}
