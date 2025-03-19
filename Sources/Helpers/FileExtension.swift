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
    public func isPDF() -> Bool {
        self == ".pdf"
    }

    public func isImage() -> Bool {
        let imageExtensions = [
            ".xpm", ".png", ".jpg", ".jpeg", ".jp2", ".gif", ".webp",
            ".tiff", ".tif", ".bmp", ".ico", ".heif", ".xcf", ".svg",
        ]
        return imageExtensions.contains(self)
    }

    public func isText() -> Bool {
        self == ".txt"
    }

    public func isRichText() -> Bool {
        [".rtf"].contains(self)
    }

    public func isWord() -> Bool {
        let wordExtensions = [".docx", ".doc"]
        return wordExtensions.contains(self)
    }

    public func isPowerPoint() -> Bool {
        let powerPointExtensions = [".pptx", ".ppt"]
        return powerPointExtensions.contains(self)
    }

    public func isExcel() -> Bool {
        let excelExtensions = [".xlsx", ".xls"]
        return excelExtensions.contains(self)
    }

    public func isMicrosoftOffice() -> Bool {
        isWord() || isPowerPoint() || isExcel()
    }

    public func isOpenOffice() -> Bool {
        isDocument() || isSpreadsheet() || isSlides()
    }

    public func isDocument() -> Bool {
        let documentExtensions = [".odt", ".ott", ".gdoc", ".pages"]
        return documentExtensions.contains(self)
    }

    public func isSpreadsheet() -> Bool {
        let spreadsheetExtensions = [".ods", ".ots", ".gsheet"]
        return spreadsheetExtensions.contains(self)
    }

    public func isSlides() -> Bool {
        let slidesExtensions = [".odp", ".otp", ".key", ".gslides"]
        return slidesExtensions.contains(self)
    }

    public func isVideo() -> Bool {
        let videoExtensions = [
            ".ogv", ".ogg", ".mpeg", ".mov", ".mqv", ".mp4", ".webm",
            ".3gp", ".3g2", ".avi", ".flv", ".mkv", ".asf", ".m4v",
        ]
        return videoExtensions.contains(self)
    }

    public func isAudio() -> Bool {
        let audioExtensions = [
            ".oga", ".mp3", ".flac", ".midi", ".ape", ".mpc", ".amr",
            ".wav", ".aiff", ".au", ".aac", "voc", ".m4a", ".qcp",
        ]
        return audioExtensions.contains(self)
    }

    public func isArchive() -> Bool {
        let archiveExtensions = [".zip", ".tar", ".7z", ".bz2", ".gz", ".rar"]
        return archiveExtensions.contains(self)
    }

    public func isFont() -> Bool {
        [".ttf", ".woff"].contains(self)
    }

    public func isCode() -> Bool {
        let codeExtensions = [
            ".html", ".js", "jsx", ".ts", ".tsx", ".css", ".sass",
            ".scss", ".go", ".py", ".rb", ".java", ".c", ".h", ".cpp",
            ".hpp", ".json", ".yml", ".yaml", ".toml", ".md",
        ]
        return codeExtensions.contains(self)
    }

    public func isCSV() -> Bool {
        [".csv"].contains(self)
    }

    public func isGLB() -> Bool {
        self == ".glb"
    }
}
