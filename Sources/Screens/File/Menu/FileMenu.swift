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

public struct FileMenu: View {
    @ObservedObject private var fileStore: FileStore
    private let onSharing: (() -> Void)?
    private let onSnapshots: (() -> Void)?
    private let onUpload: (() -> Void)?
    private let onDownload: (() -> Void)?
    private let onDelete: (() -> Void)?
    private let onRename: (() -> Void)?
    private let onMove: (() -> Void)?
    private let onCopy: (() -> Void)?

    public init(
        fileStore: FileStore,
        onSharing: (() -> Void)? = nil,
        onSnapshots: (() -> Void)? = nil,
        onUpload: (() -> Void)? = nil,
        onDownload: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onRename: (() -> Void)? = nil,
        onMove: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil
    ) {
        self.fileStore = fileStore
        self.onSharing = onSharing
        self.onSnapshots = onSnapshots
        self.onUpload = onUpload
        self.onDownload = onDownload
        self.onDelete = onDelete
        self.onRename = onRename
        self.onMove = onMove
        self.onCopy = onCopy
    }

    public var body: some View {
        Menu {
            if fileStore.isSharingAuthorized(fileStore.selection) {
                Button {
                    onSharing?()
                } label: {
                    Label("Sharing", systemImage: "person.2")
                }
            }
            if fileStore.isDownloadAuthorized(fileStore.selection) {
                Button {
                    onDownload?()
                } label: {
                    Label("Download", systemImage: "square.and.arrow.down")
                }
            }
            if fileStore.isSharingAuthorized(fileStore.selection) || fileStore.isDownloadAuthorized(fileStore.selection)
            {
                Divider()
            }
            if fileStore.isDeleteAuthorized(fileStore.selection) {
                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            if fileStore.isMoveAuthorized(fileStore.selection) {
                Button {
                    onMove?()
                } label: {
                    Label("Move", systemImage: "arrow.turn.up.right")
                }
            }
            if fileStore.isCopyAuthorized(fileStore.selection) {
                Button {
                    onCopy?()
                } label: {
                    Label("Copy", systemImage: "document.on.document")
                }
            }
        } label: {
            Label("Menu", systemImage: "ellipsis.circle")
        }
    }
}
