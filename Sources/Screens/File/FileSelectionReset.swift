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

struct FileSelectionReset: ViewModifier {
    @ObservedObject private var fileStore: FileStore

    public init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    public func body(content: Content) -> some View {
        content
            .onChange(of: fileStore.insightsIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.mosaicIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.sharingIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.snapshotsIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.uploadIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.downloadIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.moveIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.copyIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
            .onChange(of: fileStore.infoIsPresented) { _, newValue in
                if !newValue {
                    fileStore.selection = []
                }
            }
    }
}

extension View {
    public func fileSelectionReset(fileStore: FileStore) -> some View {
        modifier(FileSelectionReset(fileStore: fileStore))
    }
}
