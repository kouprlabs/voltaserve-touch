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

public struct FileUploadMenu: View {
    private let label: AnyView
    private let fileStore: FileStore

    public init(fileStore: FileStore, @ViewBuilder label: () -> some View) {
        self.fileStore = fileStore
        self.label = AnyView(label())
    }

    public var body: some View {
        if let current = fileStore.current, current.permission.ge(.editor) {
            Menu {
                Button {
                    fileStore.uploadDocumentPickerIsPresented = true
                } label: {
                    Label("Upload Files", systemImage: "icloud.and.arrow.up")
                }
                Button {
                    fileStore.createFolderIsPresented = true
                } label: {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
            } label: {
                label
            }
        }
    }
}
