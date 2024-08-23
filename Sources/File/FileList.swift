import SwiftUI

struct FileList: View {
    var files = [
        "File 1",
        "File 2",
        "File 3",
        "File 4",
        "File 5"
    ]

    var body: some View {
        NavigationStack {
            List(files, id: \.self) { file in
                NavigationLink(file) {
                    if file == "File 1" {
                        ViewerPDFBasicContainer()
                            .navigationTitle(file)
                    } else if file == "File 2" {
                        ViewerPDFContainer()
                            .navigationTitle(file)
                    } else if file == "File 3" {
                        Viewer3D()
                            .navigationTitle(file)
                    } else {
                        ViewerPDFBasicContainer()
                            .navigationTitle(file)
                    }
                }
            }
        }
    }
}

#Preview {
    FileList()
}
