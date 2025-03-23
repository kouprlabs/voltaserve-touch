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

public struct FileSheetCopy: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var destinationID: String?

    public init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $fileStore.browserForCopyIsPresented) {
                NavigationStack {
                    if let folder = fileStore.selectionFiles.first {
                        BrowserOverview(folder: folder, confirmLabelText: "Copy Here") { id in
                            destinationID = id
                            fileStore.copyIsPresented = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(folder.workspace.name)
                    }
                }
            }
            .sheet(isPresented: $fileStore.copyIsPresented) {
                if let destinationID, !fileStore.selection.isEmpty {
                    FileCopy(fileStore: fileStore, to: destinationID)
                }
            }
    }
}

extension View {
    public func fileSheetCopy(fileStore: FileStore) -> some View {
        modifier(FileSheetCopy(fileStore: fileStore))
    }
}
