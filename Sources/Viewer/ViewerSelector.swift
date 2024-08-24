import SwiftUI

struct ViewerSelector: View {
    var file: String

    init(file: String) {
        self.file = file
    }

    var body: some View {
        if file == "File 1" {
            ViewerPDFBasicContainer()
        } else if file == "File 2" {
            ViewerPDFContainer()
        } else if file == "File 3" {
            Viewer3D()
        } else if file == "File 4" {
            ViewerMosaic()
        } else {
            ViewerPDFBasicContainer()
        }
    }
}
