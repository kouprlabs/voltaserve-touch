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
    @State var tappedItem: VOFile.Entity?
    @State var searchText = ""
    @State var searchPublisher = PassthroughSubject<String, Never>()
    @State var isLoading = false
    @State var selection = Set<String>()
    @State var showRename = false
    @State var showDelete = false
    @State var showDownload = false
    @State var showBrowserForMove = false
    @State var showBrowserForCopy = false
    @State var showUploadDocumentPicker = false
    @State private var showUpload = false
    @State private var showMove = false
    @State private var showCopy = false
    @State private var showDownloadDocumentPicker = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
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
            .sheet(isPresented: $showBrowserForMove) {
                NavigationStack {
                    BrowserList(workspace.rootID, confirmLabelText: "Move Here") {
                        showMove = true
                        showBrowserForMove = false
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(workspace.name)
                }
            }
            .sheet(isPresented: $showMove) {
                let files = selectionToFiles()
                if !files.isEmpty {
                    FileMove(files) { showMove = false }
                }
            }
            .sheet(isPresented: $showBrowserForCopy) {
                NavigationStack {
                    BrowserList(workspace.rootID, confirmLabelText: "Copy Here") {
                        showCopy = true
                        showBrowserForCopy = false
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(workspace.name)
                }
            }
            .sheet(isPresented: $showCopy) {
                let files = selectionToFiles()
                if !files.isEmpty {
                    FileCopy(files) { showCopy = false }
                }
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
                        showDownloadDocumentPicker = true
                    } onDismiss: {
                        showDownload = false
                    }
                }
            }
            .sheet(isPresented: $showDownloadDocumentPicker, onDismiss: handleDismissDownloadPicker) {
                if let documentPickerURLs {
                    FileDownloadPicker(
                        sourceURLs: documentPickerURLs,
                        onDismiss: handleDismissDownloadPicker
                    )
                }
            }
            .sheet(isPresented: $showUploadDocumentPicker) {
                FileUploadPicker { urls in
                    documentPickerURLs = urls
                    showUploadDocumentPicker = false
                    showUpload = true
                }
            }
            .sheet(isPresented: $showUpload) {
                if let documentPickerURLs {
                    FileUpload(documentPickerURLs) { showUpload = false }
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
                                onUpload: { showUploadDocumentPicker = true },
                                onDownload: { showDownload = true },
                                onDelete: { showDelete = true },
                                onRename: { showRename = true },
                                onMove: { showBrowserForMove = true },
                                onCopy: { showBrowserForCopy = true }
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
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showUploadDocumentPicker = true
                        } label: {
                            Label("Upload files", systemImage: "icloud.and.arrow.up")
                        }
                        Button {} label: {
                            Label("New folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Label("Upload", systemImage: "plus")
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

    private func handleDismissDownloadPicker() {
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
        showDownloadDocumentPicker = false
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

    func onListItemAppear(_ id: String) {
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

    func fetchList(replace: Bool = false) {
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
