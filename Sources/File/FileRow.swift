import SwiftUI
import Voltaserve

struct FileRow: View {
    @Environment(\.colorScheme) var colorScheme
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            Image(iconForFile(file))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(file.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(file.createTime.relativeDate())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(VOMetrics.spacingSm)
    }

    func iconForFile(_ file: VOFile.Entity) -> String {
        guard let snapshot = file.snapshot else { return "" }
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
            image += "-dark"
        }

        return image
    }
}
