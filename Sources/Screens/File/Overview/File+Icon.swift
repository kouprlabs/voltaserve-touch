import SwiftUI
import VoltaserveCore

extension VOFile.Entity {
    func iconForFile(colorScheme: ColorScheme) -> String {
        guard let snapshot else { return "" }
        guard let fe = snapshot.original.fileExtension else { return "" }
        let hasThumbnail = snapshot.thumbnail != nil

        var image = if fe.isImage() {
            "icon-image"
        } else if fe.isPDF() {
            "icon-pdf"
        } else if fe.isText() {
            "icon-text"
        } else if fe.isRichText() {
            "icon-rich-text"
        } else if fe.isWord() {
            "icon-word"
        } else if fe.isPowerPoint() {
            "icon-power-point"
        } else if fe.isExcel() {
            "icon-spreadsheet"
        } else if fe.isDocument() {
            "icon-word"
        } else if fe.isSpreadsheet() {
            "icon-spreadsheet"
        } else if fe.isSlides() {
            "icon-power-point"
        } else if fe.isVideo(), hasThumbnail {
            "icon-video"
        } else if fe.isAudio(), !hasThumbnail {
            "icon-audio"
        } else if fe.isArchive() {
            "icon-archive"
        } else if fe.isFont() {
            "icon-file"
        } else if fe.isCode() {
            "icon-code"
        } else if fe.isCSV() {
            "icon-csv"
        } else if fe.isGLB() {
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
