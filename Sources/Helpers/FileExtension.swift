// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Foundation

extension String {
    func isPDF() -> Bool {
        self == ".pdf"
    }

    func isImage() -> Bool {
        let imageExtensions = [
            ".xpm", ".png", ".jpg", ".jpeg", ".jp2", ".gif", ".webp",
            ".tiff", ".tif", ".bmp", ".ico", ".heif", ".xcf", ".svg",
        ]
        return imageExtensions.contains(self)
    }

    func isText() -> Bool {
        self == ".txt"
    }

    func isRichText() -> Bool {
        [".rtf"].contains(self)
    }

    func isWord() -> Bool {
        let wordExtensions = [".docx", ".doc"]
        return wordExtensions.contains(self)
    }

    func isPowerPoint() -> Bool {
        let powerPointExtensions = [".pptx", ".ppt"]
        return powerPointExtensions.contains(self)
    }

    func isExcel() -> Bool {
        let excelExtensions = [".xlsx", ".xls"]
        return excelExtensions.contains(self)
    }

    func isMicrosoftOffice() -> Bool {
        isWord() || isPowerPoint() || isExcel()
    }

    func isOpenOffice() -> Bool {
        isDocument() || isSpreadsheet() || isSlides()
    }

    func isDocument() -> Bool {
        let documentExtensions = [".odt", ".ott", ".gdoc", ".pages"]
        return documentExtensions.contains(self)
    }

    func isSpreadsheet() -> Bool {
        let spreadsheetExtensions = [".ods", ".ots", ".gsheet"]
        return spreadsheetExtensions.contains(self)
    }

    func isSlides() -> Bool {
        let slidesExtensions = [".odp", ".otp", ".key", ".gslides"]
        return slidesExtensions.contains(self)
    }

    func isVideo() -> Bool {
        let videoExtensions = [
            ".ogv", ".ogg", ".mpeg", ".mov", ".mqv", ".mp4", ".webm",
            ".3gp", ".3g2", ".avi", ".flv", ".mkv", ".asf", ".m4v",
        ]
        return videoExtensions.contains(self)
    }

    func isAudio() -> Bool {
        let audioExtensions = [
            ".oga", ".mp3", ".flac", ".midi", ".ape", ".mpc", ".amr",
            ".wav", ".aiff", ".au", ".aac", "voc", ".m4a", ".qcp",
        ]
        return audioExtensions.contains(self)
    }

    func isArchive() -> Bool {
        let archiveExtensions = [".zip", ".tar", ".7z", ".bz2", ".gz", ".rar"]
        return archiveExtensions.contains(self)
    }

    func isFont() -> Bool {
        [".ttf", ".woff"].contains(self)
    }

    func isCode() -> Bool {
        let codeExtensions = [
            ".html", ".js", "jsx", ".ts", ".tsx", ".css", ".sass",
            ".scss", ".go", ".py", ".rb", ".java", ".c", ".h", ".cpp",
            ".hpp", ".json", ".yml", ".yaml", ".toml", ".md",
        ]
        return codeExtensions.contains(self)
    }

    func isCSV() -> Bool {
        [".csv"].contains(self)
    }

    func isGLB() -> Bool {
        self == ".glb"
    }
}
