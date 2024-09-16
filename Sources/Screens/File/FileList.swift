import Combine
import SwiftUI
import UIKit
import VoltaserveCore

struct FileList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.editMode) private var editMode
    @State var selection = Set<String>()
    @State var showMove = false
    @State var showCopy = false
    @State var showRename = false
    @State var showDelete = false
    @State var showDownload = false
    @State private var showDocumentPicker = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var tappedItem: VOFile.Entity?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false
    @State private var viewMode: ViewMode
    @State private var documentPickerURLs: [URL]?
    private let id: String

    init(_ id: String) {
        self.id = id
        if let viewMode = UserDefaults.standard.string(forKey: Constants.userDefaultViewModeKey) {
            self.viewMode = ViewMode(rawValue: viewMode)!
        } else {
            viewMode = .grid
        }
    }

    var body: some View {
        if let workspace = workspaceStore.current {
            VStack {
                if let entities = fileStore.entities {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        if viewMode == .list {
                            listView(entities)
                        } else if viewMode == .grid {
                            gridView(entities)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                Button(VOTextConstants.errorAlertButtonLabel) {}
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showMove) {
                FileMove(
                    workspace: workspace,
                    selection: selection,
                    isVisible: $showMove
                )
            }
            .sheet(isPresented: $showCopy) {
                FileCopy(
                    workspace: workspace,
                    selection: selection,
                    isVisible: $showCopy
                )
            }
            .sheet(isPresented: $showRename) {
                if !selection.isEmpty {
                    FileRename(selection.first!) { showRename = false }
                }
            }
            .sheet(isPresented: $showDelete) {
                if !selection.isEmpty {
                    FileDelete(selection) { showDelete = false }
                }
            }
            .sheet(isPresented: $showDownload) {
                let files = selectionToFiles()
                if !files.isEmpty {
                    FileDownload(files) { localURLs in
                        showDownload = false
                        documentPickerURLs = localURLs
                        showDocumentPicker = true
                    } onDismiss: {
                        showDownload = false
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker, onDismiss: handleDismissDocumentPicker) {
                if let documentPickerURLs {
                    DocumentPicker(sourceURLs: documentPickerURLs, onDismiss: handleDismissDocumentPicker)
                }
            }
            .toolbar {
                if viewMode == .list {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                    if editMode?.wrappedValue.isEditing == true, selection.count > 0 {
                        ToolbarItem(placement: .bottomBar) {
                            FileMenu(
                                selection,
                                onDownload: { showDownload = true },
                                onDelete: { showDelete = true },
                                onRename: { showRename = true },
                                onMove: { showMove = true },
                                onCopy: { showCopy = true }
                            )
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewMode = viewMode == .list ? .grid : .list
                        UserDefaults.standard.set(viewMode.rawValue, forKey: Constants.userDefaultViewModeKey)
                    } label: {
                        Label("View Mode", systemImage: viewMode == .list ? "square.grid.2x2" : "list.bullet")
                    }
                }
            }
            .onAppear {
                fileStore.clear()
                searchPublisher
                    .debounce(for: .seconds(1), scheduler: RunLoop.main)
                    .removeDuplicates()
                    .sink { fileStore.query = .init(text: $0) }
                    .store(in: &cancellables)
                if authStore.token != nil {
                    onAppearOrChange()
                }
            }
            .onDisappear {
                fileStore.stopTimer()
                cancellables.forEach { $0.cancel() }
                cancellables.removeAll()
            }
            .onChange(of: authStore.token) { _, newToken in
                if newToken != nil {
                    onAppearOrChange()
                }
            }
            .onChange(of: fileStore.query) {
                fetchList(replace: true)
            }
        } else {
            ProgressView()
        }
    }

    @ViewBuilder
    private func listView(_ entities: [VOFile.Entity]) -> some View {
        List(selection: $selection) {
            ForEach(entities, id: \.id) { file in
                if file.type == .file {
                    Button {
                        tappedItem = file
                    } label: {
                        FileRow(file)
                            .fileContextMenuWithActions(file, list: self)
                    }
                    .onAppear { onListItemAppear(file.id) }
                } else if file.type == .folder {
                    NavigationLink {
                        FileList(file.id)
                            .navigationTitle(file.name)
                    } label: {
                        FileRow(file)
                            .fileContextMenuWithActions(file, list: self)
                    }
                    .onAppear { onListItemAppear(file.id) }
                }
            }
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .listStyle(.inset)
        .searchable(text: $searchText)
        .onChange(of: searchText) { searchPublisher.send($1) }
        .refreshable {
            fetchList(replace: true)
        }
        .navigationDestination(item: $tappedItem) { FileViewer($0) }
    }

    @ViewBuilder
    private func gridView(_ entities: [VOFile.Entity]) -> some View {
        GeometryReader { geometry in
            let columns = Array(
                repeating: GridItem(.fixed(FileMetrics.cellSize.width), spacing: VOMetrics.spacing),
                count: Int(geometry.size.width / FileMetrics.cellSize.width)
            )
            ScrollView {
                LazyVGrid(columns: columns, spacing: VOMetrics.spacing) {
                    ForEach(entities, id: \.id) { file in
                        if file.type == .file {
                            Button {
                                tappedItem = file
                            } label: {
                                FileCell(file)
                                    .fileContextMenuWithActions(file, list: self)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear { onListItemAppear(file.id) }
                        } else if file.type == .folder {
                            NavigationLink {
                                FileList(file.id)
                                    .navigationTitle(file.name)
                            } label: {
                                FileCell(file)
                                    .fileContextMenuWithActions(file, list: self)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear { onListItemAppear(file.id) }
                        }
                    }
                }
                .navigationDestination(item: $tappedItem) { FileViewer($0) }
                .padding(.vertical, VOMetrics.spacing)
            }
        }
    }

    private func handleDismissDocumentPicker() {
        if let documentPickerURLs {
            let fileManager = FileManager.default
            for url in documentPickerURLs where fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func selectionToFiles() -> [VOFile.Entity] {
        var files: [VOFile.Entity] = []
        for id in selection {
            let file = fileStore.entities?.first(where: { $0.id == id })
            if let file {
                files.append(file)
            }
        }
        return files
    }

    private func onAppearOrChange() {
        fetchFile()
        fetchList(replace: true)
        fileStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if fileStore.isLast(id) {
            fetchList()
        }
    }

    private func fetchFile() {
        Task {
            do {
                let file = try await fileStore.fetch(id)
                Task { @MainActor in
                    fileStore.current = file
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    errorMessage = error.userMessage
                    showError = true
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }

    private func fetchList(replace: Bool = false) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !fileStore.hasNextPage() { return }
                let nextPage = fileStore.nextPage()
                let list = try await fileStore.fetchList(id, page: nextPage)
                Task { @MainActor in
                    fileStore.list = list
                    if let list {
                        if replace, nextPage == 1 {
                            fileStore.entities = list.data
                        } else {
                            fileStore.append(list.data)
                        }
                    }
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    errorMessage = error.userMessage
                    showError = true
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }

    enum ViewMode: String {
        case list
        case grid
    }

    private enum Constants {
        static let userDefaultViewModeKey = "com.voltaserve.files.viewMode"
    }
}

struct FileContextMenuWithActions: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    var file: VOFile.Entity
    var list: FileList

    init(_ file: VOFile.Entity, list: FileList) {
        self.file = file
        self.list = list
    }

    func body(content: Content) -> some View {
        content
            .fileContextMenu(
                file,
                selection: list.$selection,
                onDownload: { list.showDownload = true },
                onDelete: { list.showDelete = true },
                onRename: { list.showRename = true },
                onMove: { list.showMove = true },
                onCopy: { list.showCopy = true },
                onOpen: {
                    if let snapshot = file.snapshot,
                       let fileExtension = snapshot.original.fileExtension,
                       let url = fileStore.urlForOriginal(file.id, fileExtension: String(fileExtension.dropFirst())) {
                        UIApplication.shared.open(url)
                    }
                }
            )
    }
}

extension View {
    func fileContextMenuWithActions(_ file: VOFile.Entity, list: FileList) -> some View {
        modifier(FileContextMenuWithActions(file, list: list))
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let sourceURLs: [URL]
    let onDismiss: (() -> Void)?

    init(sourceURLs: [URL], onDismiss: (() -> Void)? = nil) {
        self.sourceURLs = sourceURLs
        self.onDismiss = onDismiss
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sourceURLs: sourceURLs, onDismiss: onDismiss)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forExporting: sourceURLs)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let sourceURLs: [URL]
        let onDismiss: (() -> Void)?

        init(sourceURLs: [URL], onDismiss: (() -> Void)?) {
            self.sourceURLs = sourceURLs
            self.onDismiss = onDismiss
        }

        func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
            onDismiss?()
        }
    }
}
