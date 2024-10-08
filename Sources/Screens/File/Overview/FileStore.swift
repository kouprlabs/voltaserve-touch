import Combine
import Foundation
import VoltaserveCore

// swiftlint:disable:next type_body_length
class FileStore: ObservableObject {
    @Published var list: VOFile.List?
    @Published var entities: [VOFile.Entity]?
    @Published var taskCount: Int?
    @Published var id: String?
    @Published var file: VOFile.Entity?
    @Published var query: VOFile.Query?

    @Published var selection = Set<String>() {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var showRename = false
    @Published var showDelete = false
    @Published var showDownload = false
    @Published var showBrowserForMove = false
    @Published var showBrowserForCopy = false
    @Published var showUploadDocumentPicker = false
    @Published var showDownloadDocumentPicker = false
    @Published var showNewFolder = false
    @Published var showUpload = false
    @Published var showMove = false
    @Published var showCopy = false
    @Published var showSharing = false
    @Published var showTasks = false
    @Published var viewMode: ViewMode = .grid
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var fileClient: VOFile?
    private var taskClient: VOTask?
    let searchPublisher = PassthroughSubject<String, Never>()

    var token: VOToken.Value? {
        didSet {
            if let token {
                fileClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
                taskClient = VOTask(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    var selectionFiles: [VOFile.Entity] {
        var files: [VOFile.Entity] = []
        for id in selection {
            let file = entities?.first(where: { $0.id == id })
            if let file {
                files.append(file)
            }
        }
        return files
    }

    init() {
        loadViewModeFromUserDefaults()
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = .init(text: $0)
            }
            .store(in: &cancellables)
    }

    func createFolder(name: String, workspaceID: String, parentID: String) async throws -> VOFile.Entity? {
        try await Fake.serverCall { (continuation: CheckedContinuation<VOFile.Entity, any Error>) in
            if name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume(returning: VOFile.Entity(
                    id: UUID().uuidString,
                    workspaceID: workspaceID,
                    name: name,
                    type: .folder,
                    parentID: parentID,
                    permission: .owner,
                    createTime: Date().ISO8601Format()
                ))
            }
        }
    }

    func fetch(_ id: String) async throws -> VOFile.Entity? {
        try await fileClient?.fetch(id)
    }

    func fetch() {
        guard let id else { return }

        var file: VOFile.Entity?
        withErrorHandling {
            file = try await self.fetch(id)
            return true
        } success: {
            self.file = file
        } failure: { message in
            self.errorTitle = "Error: Fetching File"
            self.errorMessage = message
            self.showError = true
        }
    }

    func fetchList(_ id: String, page: Int = 1, size: Int = Constants.pageSize) async throws -> VOFile.List? {
        try await fileClient?.fetchList(id, options: .init(query: query, page: page, size: size))
    }

    func fetchList(replace: Bool = false) {
        guard let id else { return }

        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOFile.List?

        withErrorHandling {
            if !self.hasNextPage() { return false }
            nextPage = self.nextPage()
            list = try await self.fetchList(id, page: nextPage)
            return true
        } success: {
            self.list = list
            if let list {
                if replace, nextPage == 1 {
                    self.entities = list.data
                } else {
                    self.append(list.data)
                }
            }
        } failure: { message in
            self.errorTitle = "Error: Fetching Files"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func fetchTaskCount() async throws -> Int? {
        try await taskClient?.fetchCount()
    }

    func fetchTaskCount() {
        var taskCount: Int?
        withErrorHandling {
            taskCount = try await self.fetchTaskCount()
            return true
        } success: {
            self.taskCount = taskCount
        } failure: { message in
            self.errorTitle = "Error: Fetching Task Count"
            self.errorMessage = message
            self.showError = true
        }
    }

    func patchName(_: String, name: String) async throws {
        try await Fake.serverCall { continuation in
            if name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func copy(_ ids: [String], to _: String) async throws -> VOFile.CopyResult {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<VOFile.CopyResult, any Error>) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                if ids.count == 2 {
                    continuation.resume(returning: VOFile.CopyResult(
                        new: [],
                        succeeded: [],
                        failed: ids
                    ))
                } else if ids.count == 3 {
                    continuation.resume(returning: VOFile.CopyResult(
                        new: [ids[1], ids[2]],
                        succeeded: [ids[1], ids[2]],
                        failed: [ids[0]]
                    ))
                } else {
                    continuation.resume(returning: VOFile.CopyResult(
                        new: ids,
                        succeeded: ids,
                        failed: []
                    ))
                }
            }
        }
    }

    func move(_ ids: [String], to _: String) async throws -> VOFile.MoveResult {
        try await Fake.serverCall { (continuation: CheckedContinuation<VOFile.MoveResult, any Error>) in
            if ids.count == 2 {
                continuation.resume(returning: VOFile.MoveResult(
                    succeeded: [],
                    failed: ids
                ))
            } else if ids.count == 3 {
                continuation.resume(returning: VOFile.MoveResult(
                    succeeded: [ids[1], ids[2]],
                    failed: [ids[0]]
                ))
            } else {
                continuation.resume(returning: VOFile.MoveResult(
                    succeeded: ids,
                    failed: []
                ))
            }
        }
    }

    func delete(_ ids: [String]) async throws -> VOFile.DeleteResult {
        try await Fake.serverCall { continuation in
            if ids.count == 2 {
                continuation.resume(returning: VOFile.DeleteResult(
                    succeeded: [],
                    failed: ids
                ))
            } else if ids.count == 3 {
                continuation.resume(returning: VOFile.DeleteResult(
                    succeeded: [ids[1], ids[2]],
                    failed: [ids[0]]
                ))
            } else {
                continuation.resume(returning: VOFile.DeleteResult(
                    succeeded: ids,
                    failed: []
                ))
            }
        }
    }

    func upload(_ url: URL, workspaceID _: String) async throws {
        try await Fake.serverCall { continuation in
            if url.lastPathComponent.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func urlForThumbnail(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForThumbnail(id, fileExtension: fileExtension)
    }

    func urlForPreview(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForPreview(id, fileExtension: fileExtension)
    }

    func urlForOriginal(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForOriginal(id, fileExtension: fileExtension)
    }

    func append(_ newEntities: [VOFile.Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities where !entities!.contains(where: { $0.id == newEntity.id }) {
            entities!.append(newEntity)
        }
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
            if self.isLoading { return }
            if let file = self.file {
                Task {
                    var size = Constants.pageSize
                    if let list = self.list {
                        size = Constants.pageSize * list.page
                    }
                    let list = try await self.fetchList(file.id, page: 1, size: size)
                    if let list {
                        DispatchQueue.main.async {
                            self.entities = list.data
                        }
                    }
                }
            }
            if let file = self.file {
                Task {
                    let file = try await self.fetch(file.id)
                    if let file {
                        DispatchQueue.main.async {
                            self.file = file
                        }
                    }
                }
            }
            Task {
                let taskCount = try await self.fetchTaskCount()
                DispatchQueue.main.async {
                    self.taskCount = taskCount
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
        file.permission.ge(.editor)
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

    func loadViewModeFromUserDefaults() {
        if let viewMode = UserDefaults.standard.string(forKey: Constants.userDefaultViewModeKey) {
            self.viewMode = ViewMode(rawValue: viewMode)!
        }
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
