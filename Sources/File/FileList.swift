import SwiftUI

struct FileList: View {
    private var files = [
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
                    ViewerSelector(file: file)
                        .navigationTitle(file)
                }
            }
            .listStyle(.inset)
        }
    }
}

#Preview {
    FileList()
}
