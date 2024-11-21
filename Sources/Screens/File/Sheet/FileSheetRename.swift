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

struct FileSheetRename: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showRename = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showRename) {
                if !fileStore.selection.isEmpty, let file = fileStore.selectionFiles.first {
                    FileRename(file) { updatedFile in
                        if let index = fileStore.entities?.firstIndex(where: { $0.id == file.id }) {
                            fileStore.entities?[index] = updatedFile
                        }
                    }
                }
            }
            .sync($fileStore.showRename, with: $showRename)
    }
}

extension View {
    func fileSheetRename(fileStore: FileStore) -> some View {
        modifier(FileSheetRename(fileStore: fileStore))
    }
}
