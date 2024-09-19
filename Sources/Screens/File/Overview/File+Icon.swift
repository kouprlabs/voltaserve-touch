import SwiftUI
import VoltaserveCore

extension VOFile.Entity {
    // swiftlint:disable:next cyclomatic_complexity
    func iconForFile(colorScheme: ColorScheme) -> String {
        guard let snapshot else { return "" }
        guard let fileExtension = snapshot.original.fileExtension else { return "" }
        let hasThumbnail = snapshot.thumbnail != nil

        var image = if fileExtension.isImage() {
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
