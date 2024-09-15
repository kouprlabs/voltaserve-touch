import Combine
import SwiftUI
import VoltaserveCore

struct FileList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.editMode) private var editMode
    @State private var selection = Set<String>()
    @State private var showMove = false
    @State private var showCopy = false
    @State private var showRename = false
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var tappedItem: VOFile.Entity?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false
    @State private var viewMode: ViewMode
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
                            List(selection: $selection) {
                                ForEach(entities, id: \.id) { file in
                                    if file.type == .file {
                                        Button {
                                            tappedItem = file
                                        } label: {
                                            FileRow(file)
                                                .fileContextMenu(
                                                    file,
                                                    selection: $selection,
                                                    onDelete: { showDelete = true },
                                                    onRename: { showRename = true },
                                                    onMove: { showMove = true },
                                                    onCopy: { showCopy = true }
                                                )
                                        }
                                        .onAppear { onListItemAppear(file.id) }
                                    } else if file.type == .folder {
                                        NavigationLink {
                                            FileList(file.id)
                                                .navigationTitle(file.name)
                                        } label: {
                                            FileRow(file)
                                                .fileContextMenu(
                                                    file,
                                                    selection: $selection,
                                                    onDelete: { showDelete = true },
                                                    onRename: { showRename = true },
                                                    onMove: { showMove = true },
                                                    onCopy: { showCopy = true }
                                                )
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
                        } else if viewMode == .grid {
                            GeometryReader { geometry in
                                let columns = Array(
                                    repeating: GridItem(.fixed(FileCell.Constants.width), spacing: VOMetrics.spacing),
                                    count: Int(geometry.size.width / FileCell.Constants.width)
                                )
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: VOMetrics.spacing) {
                                        ForEach(entities, id: \.id) { file in
                                            if file.type == .file {
                                                Button {
                                                    tappedItem = file
                                                } label: {
                                                    FileCell(file)
                                                        .fileContextMenu(
                                                            file,
                                                            selection: $selection,
                                                            onDelete: { showDelete = true },
                                                            onRename: { showRename = true },
                                                            onMove: { showMove = true },
                                                            onCopy: { showCopy = true }
                                                        )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .onAppear { onListItemAppear(file.id) }
                                            } else if file.type == .folder {
                                                NavigationLink {
                                                    FileList(file.id)
                                                        .navigationTitle(file.name)
                                                } label: {
                                                    FileCell(file)
                                                        .fileContextMenu(
                                                            file,
                                                            selection: $selection,
                                                            onDelete: { showDelete = true },
                                                            onRename: { showRename = true },
                                                            onMove: { showMove = true },
                                                            onCopy: { showCopy = true }
                                                        )
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
            .toolbar {
                if viewMode == .list {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                    if editMode?.wrappedValue.isEditing == true, selection.count > 0 {
                        ToolbarItem(placement: .bottomBar) {
                            FileMenu(
                                selection,
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
