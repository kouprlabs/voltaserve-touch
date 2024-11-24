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

struct FileSheetMosaic: ViewModifier {
    @ObservedObject private var fileStore: FileStore

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $fileStore.mosaicIsPresented) {
                if let file, let snapshot = file.snapshot {
                    if snapshot.hasMosaic() {
                        MosaicSettings(file)
                    } else {
                        MosaicCreate(file.id)
                    }
                }
            }
    }

    private var file: VOFile.Entity? {
        if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
            return file
        }
        return nil
    }
}

extension View {
    func fileSheetMosaic(fileStore: FileStore) -> some View {
        modifier(FileSheetMosaic(fileStore: fileStore))
    }
}
