import Combine
import Foundation
import VoltaserveCore

class FileStore: ObservableObject {
    @Published var list: VOFile.List?
    @Published var entities: [VOFile.Entity]?
    @Published var id: String?
    @Published var file: VOFile.Entity?
    @Published var query: VOFile.Query?
    @Published var selection = Set<String>()
    @Published var showRename = false
    @Published var showDelete = false
    @Published var showDownload = false
    @Published var showBrowserForMove = false
    @Published var showBrowserForCopy = false
    @Published var showUploadDocumentPicker = false
    @Published var showUpload = false
    @Published var showMove = false
    @Published var showCopy = false
    @Published var showDownloadDocumentPicker = false
    @Published var viewMode: ViewMode
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    private(set) var searchPublisher = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOFile?

    init() {
        if let viewMode = UserDefaults.standard.string(forKey: Constants.userDefaultViewModeKey) {
            self.viewMode = ViewMode(rawValue: viewMode)!
        } else {
            viewMode = .grid
        }
    }

    func createSearchPublisher() {
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { self.query = .init(text: $0) }
            .store(in: &cancellables)
    }

    func destroySearchPublisher() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func fetch(_ id: String) async throws -> VOFile.Entity? {
        try await client?.fetch(id)
    }

    func fetch() {
        guard let id else { return }
        Task {
            do {
                let file = try await fetch(id)
                Task { @MainActor in
                    self.file = file
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

    func fetchList(_ id: String, page: Int = 1, size: Int = Constants.pageSize) async throws -> VOFile.List? {
        try await client?.fetchList(id, options: .init(query: query, page: page, size: size))
    }

    func fetchList(replace: Bool = false) {
        guard let id else { return }
        Task {
            Task { @MainActor in
                isLoading = true
            }
            defer {
                Task { @MainActor in
                    isLoading = false
                }
            }
            do {
                if !hasNextPage() { return }
                let nextPage = nextPage()
                let list = try await fetchList(id, page: nextPage)
                Task { @MainActor in
                    self.list = list
                    if let list {
                        if replace, nextPage == 1 {
                            entities = list.data
                        } else {
                            append(list.data)
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

    func urlForThumbnail(_ id: String, fileExtension: String) -> URL? {
        client?.urlForThumbnail(id, fileExtension: fileExtension)
    }

    func urlForPreview(_ id: String, fileExtension: String) -> URL? {
        client?.urlForPreview(id, fileExtension: fileExtension)
    }

    func urlForOriginal(_ id: String, fileExtension: String) -> URL? {
        client?.urlForOriginal(id, fileExtension: fileExtension)
    }

    func append(_ newEntities: [VOFile.Entity]) {
        if entities == nil {
            entities = []
        }
        entities!.append(contentsOf: newEntities)
    }

    func clear() {
        entities = nil
        list = nil
    }

    func nextPage() -> Int {
        var page = 1
        if let list {
            if list.page < list.totalPages {
                page = list.page + 1
            } else if list.page == list.totalPages {
                return -1
            }
        }
        return page
    }

    func hasNextPage() -> Bool {
        nextPage() != -1
    }

    func isLast(_ id: String) -> Bool {
        id == entities?.last?.id
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if let entities = self.entities, let file = self.file, !entities.isEmpty {
                Task {
                    let list = try await self.fetchList(file.id, page: 1, size: entities.count)
                    if let list {
                        Task { @MainActor in
                            self.entities = list.data
                        }
                    }
                }
            }
            if let file = self.file {
                Task {
                    let file = try await self.fetch(file.id)
                    if let file {
                        Task { @MainActor in
                            self.file = file
                        }
                    }
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func isOwnerInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.permission.ge(.owner) }
    }

    func isEditorInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.permission.ge(.editor) }
    }

    func isViewerInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.permission.ge(.viewer) }
    }

    func isFilesInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.type == .file }
    }

    func isInsightsAuthorized(_ file: VOFile.Entity) -> Bool {
        guard let snapshot = file.snapshot else { return false }
        guard let fileExtension = snapshot.original.fileExtension else { return false }
        return file.type == .file &&
            !(file.snapshot?.task?.isPending ?? false) &&
            (fileExtension.isPDF() ||
                fileExtension.isMicrosoftOffice() ||
                fileExtension.isOpenOffice() ||
                fileExtension.isImage()) &&
            ((file.permission.ge(.viewer) && snapshot.entities != nil) ||
                file.permission.ge(.editor))
    }

    func isMosaicAuthorized(_ file: VOFile.Entity) -> Bool {
        guard let snapshot = file.snapshot else { return false }
        guard let fileExtension = snapshot.original.fileExtension else { return false }
        return file.type == .file &&
            !(snapshot.task?.isPending ?? false) &&
            fileExtension.isImage()
    }

    func isSharingAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.owner)
    }

    func isSharingAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isOwnerInSelection(selection)
    }

    func isDeleteAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.owner)
    }

    func isDeleteAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isOwnerInSelection(selection)
    }

    func isMoveAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.editor)
    }

    func isMoveAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isEditorInSelection(selection)
    }

    func isCopyAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.editor)
    }

    func isCopyAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isEditorInSelection(selection)
    }

    func isSnapshotsAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.owner)
    }

    func isUploadAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.editor)
    }

    func isDownloadAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.viewer)
    }

    func isDownloadAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isViewerInSelection(selection) && isFilesInSelection(selection)
    }

    func isRenameAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.editor)
    }

    func isToolsAuthorized(_ file: VOFile.Entity) -> Bool {
        isInsightsAuthorized(file) || isMosaicAuthorized(file)
    }

    func isManagementAuthorized(_ file: VOFile.Entity) -> Bool {
        isSharingAuthorized(file) ||
            isSnapshotsAuthorized(file) ||
            isUploadAuthorized(file) ||
            isDownloadAuthorized(file)
    }

    func isOpenAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.viewer)
    }

    func toggleViewMode() {
        viewMode = viewMode == .list ? .grid : .list
        UserDefaults.standard.set(viewMode.rawValue, forKey: Constants.userDefaultViewModeKey)
    }

    enum ViewMode: String {
        case list
        case grid
    }

    private enum Constants {
        static let pageSize = 10
        static let userDefaultViewModeKey = "com.voltaserve.files.viewMode"
    }
}
