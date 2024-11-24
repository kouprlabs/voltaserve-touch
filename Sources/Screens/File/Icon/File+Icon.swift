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

extension VOFile.Entity {
    // swiftlint:disable:next cyclomatic_complexity
    func iconForFile(colorScheme: ColorScheme) -> String {
        guard let snapshot else { return "" }
        guard let fileExtension = snapshot.original.fileExtension else { return "" }
        let hasThumbnail = snapshot.thumbnail != nil

        var image =
            if fileExtension.isImage() {
                "icon-image"
            } else if fileExtension.isPDF() {
                "icon-pdf"
            } else if fileExtension.isText() {
                "icon-text"
            } else if fileExtension.isRichText() {
                "icon-rich-text"
            } else if fileExtension.isWord() {
                "icon-word"
            } else if fileExtension.isPowerPoint() {
                "icon-power-point"
            } else if fileExtension.isExcel() {
                "icon-spreadsheet"
            } else if fileExtension.isDocument() {
                "icon-word"
            } else if fileExtension.isSpreadsheet() {
                "icon-spreadsheet"
            } else if fileExtension.isSlides() {
                "icon-power-point"
            } else if fileExtension.isVideo(), hasThumbnail {
                "icon-video"
            } else if fileExtension.isAudio(), !hasThumbnail {
                "icon-audio"
            } else if fileExtension.isArchive() {
                "icon-archive"
            } else if fileExtension.isFont() {
                "icon-file"
            } else if fileExtension.isCode() {
                "icon-code"
            } else if fileExtension.isCSV() {
                "icon-csv"
            } else if fileExtension.isGLB() {
                "icon-model"
            } else {
                "icon-file"
            }

        if colorScheme == .dark {
            image = "dark-" + image
        }

        return image
    }
}
