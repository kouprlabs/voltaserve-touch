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

public struct FileSheetDelete: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var deleteIsPresented = false

    public init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                fileStore.selection.count == 1
                    ? "Are you sure you want to delete this item?"
                    : "Are you sure you want to delete \(fileStore.selection.count) items?",
                isPresented: $fileStore.deleteConfirmationIsPresented
            ) {
                Button(
                    fileStore.selection.count == 1 ? "Delete Item" : "Delete \(fileStore.selection.count) Items",
                    role: .destructive
                ) {
                    deleteIsPresented = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $deleteIsPresented) {
                FileDelete(fileStore: fileStore)
            }
    }
}

extension View {
    public func fileSheetDelete(fileStore: FileStore) -> some View {
        modifier(FileSheetDelete(fileStore: fileStore))
    }
}
