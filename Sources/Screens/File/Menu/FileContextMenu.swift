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

public struct FileContextMenu: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    private var file: VOFile.Entity
    private var onInsights: (() -> Void)?
    private var onMosaic: (() -> Void)?
    private var onSharing: (() -> Void)?
    private var onSnapshots: (() -> Void)?
    private var onUpload: (() -> Void)?
    private var onDownload: (() -> Void)?
    private var onDelete: (() -> Void)?
    private var onRename: (() -> Void)?
    private var onMove: (() -> Void)?
    private var onCopy: (() -> Void)?
    private var onOpen: (() -> Void)?
    private var onInfo: (() -> Void)?

    public init(
        _ file: VOFile.Entity,
        fileStore: FileStore,
        onInsights: (() -> Void)? = nil,
        onMosaic: (() -> Void)? = nil,
        onSharing: (() -> Void)? = nil,
        onSnapshots: (() -> Void)? = nil,
        onUpload: (() -> Void)? = nil,
        onDownload: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onRename: (() -> Void)? = nil,
        onMove: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil,
        onOpen: (() -> Void)? = nil,
        onInfo: (() -> Void)? = nil
    ) {
        self.file = file
        self.fileStore = fileStore
        self.onInsights = onInsights
        self.onMosaic = onMosaic
        self.onSharing = onSharing
        self.onSnapshots = onSnapshots
        self.onUpload = onUpload
        self.onDownload = onDownload
        self.onDelete = onDelete
        self.onRename = onRename
        self.onMove = onMove
        self.onCopy = onCopy
        self.onOpen = onOpen
        self.onInfo = onInfo
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    public func body(content: Content) -> some View {
        content
            .contextMenu {
                if fileStore.isOpenAuthorized(file) {
                    Button {
                        updateSelection()
                        onOpen?()
                    } label: {
                        Label("Open", systemImage: "arrow.up.forward")
                    }
                    Divider()
                }
                if fileStore.isInsightsAuthorized(file) || fileStore.isMosaicAuthorized(file) {
                    if fileStore.isInsightsAuthorized(file) {
                        Button {
                            updateSelection()
                            onInsights?()
                        } label: {
                            Label("Insights", systemImage: "eye")
                        }
                    }
                    if fileStore.isMosaicAuthorized(file) {
                        Button {
                            updateSelection()
                            onMosaic?()
                        } label: {
                            Label("Mosaic", systemImage: "flame")
                        }
                    }
                    Divider()
                }
                if fileStore.isManagementAuthorized(file) {
                    if fileStore.isSharingAuthorized(file) {
                        Button {
                            updateSelection()
                            onSharing?()
                        } label: {
                            Label("Sharing", systemImage: "person.2")
                        }
                    }
                    if fileStore.isSnapshotsAuthorized(file) {
                        Button {
                            updateSelection()
                            onSnapshots?()
                        } label: {
                            Label(
                                "Snapshots",
                                systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90"
                            )
                        }
                    }
                    if fileStore.isUploadAuthorized(file) {
                        Button {
                            updateSelection()
                            onUpload?()
                        } label: {
                            Label("Upload", systemImage: "square.and.arrow.up")
                        }
                    }
                    if fileStore.isDownloadAuthorized(file) {
                        Button {
                            updateSelection()
                            onDownload?()
                        } label: {
                            Label("Download", systemImage: "square.and.arrow.down")
                        }
                    }
                    Divider()
                }
                if fileStore.isDeleteAuthorized(file) {
                    Button(role: .destructive) {
                        updateSelection()
                        onDelete?()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                if fileStore.isRenameAuthorized(file) {
                    Button {
                        updateSelection()
                        onRename?()
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                }
                if fileStore.isMoveAuthorized(file) {
                    Button {
                        updateSelection()
                        onMove?()
                    } label: {
                        Label("Move", systemImage: "arrow.turn.up.right")
                    }
                }
                if fileStore.isCopyAuthorized(file) {
                    Button {
                        updateSelection()
                        onCopy?()
                    } label: {
                        Label("Copy", systemImage: "document.on.document")
                    }
                }
                if fileStore.isInfoAuthorized(file) {
                    Divider()
                    Button {
                        updateSelection()
                        onInfo?()
                    } label: {
                        Label("Info", systemImage: "info.circle")
                    }
                }
            }
    }

    private func updateSelection() {
        fileStore.selection = [file.id]
    }
}

extension View {
    public func fileContextMenu(
        _ file: VOFile.Entity,
        fileStore: FileStore,
        onInsights: (() -> Void)? = nil,
        onMosaic: (() -> Void)? = nil,
        onSharing: (() -> Void)? = nil,
        onSnapshots: (() -> Void)? = nil,
        onUpload: (() -> Void)? = nil,
        onDownload: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onRename: (() -> Void)? = nil,
        onMove: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil,
        onOpen: (() -> Void)? = nil,
        onInfo: (() -> Void)? = nil
    ) -> some View {
        modifier(
            FileContextMenu(
                file,
                fileStore: fileStore,
                onInsights: onInsights,
                onMosaic: onMosaic,
                onSharing: onSharing,
                onSnapshots: onSnapshots,
                onUpload: onUpload,
                onDownload: onDownload,
                onDelete: onDelete,
                onRename: onRename,
                onMove: onMove,
                onCopy: onCopy,
                onOpen: onOpen,
                onInfo: onInfo
            ))
    }
}
