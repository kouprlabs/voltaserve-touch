// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import Foundation
import VoltaserveCore

// swiftlint:disable:next type_body_length
class FileStore: ObservableObject {
    @Published var entities: [VOFile.Entity]?
    @Published var entitiesIsLoading: Bool = false
    @Published var entitiesError: String?
    @Published var taskCount: Int?
    @Published var taskCountIsLoading: Bool = false
    @Published var taskCountError: String?
    @Published var storageUsage: VOStorage.Usage?
    @Published var storageUsageIsLoading: Bool = false
    @Published var storageUsageError: String?
    @Published var itemCount: Int?
    @Published var itemCountIsLoading: Bool = false
    @Published var itemCountError: String?
    @Published var file: VOFile.Entity?
    @Published var fileIsLoading: Bool = false
    @Published var fileError: String?
    @Published var query: VOFile.Query?
    @Published var selection = Set<String>() {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var renameIsPresented = false
    @Published var deleteIsPresented = false
    @Published var downloadIsPresented = false
    @Published var browserForMoveIsPresented = false
    @Published var browserForCopyIsPresented = false
    @Published var uploadDocumentPickerIsPresented = false
    @Published var downloadDocumentPickerIsPresented = false
    @Published var createFolderIsPresented = false
    @Published var uploadIsPresented = false
    @Published var moveIsPresented = false
    @Published var copyIsPresented = false
    @Published var sharingIsPresented = false
    @Published var snapshotsIsPresented = false
    @Published var tasksIsPresented = false
    @Published var mosaicIsPresented = false
    @Published var insightsIsPresented = false
    @Published var infoIsPresented = false
    @Published var viewMode: ViewMode = .grid
    @Published var searchText = ""
    private var list: VOFile.List?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var fileClient: VOFile?
    private var taskClient: VOTask?
    private var storageClient: VOStorage?
    let searchPublisher = PassthroughSubject<String, Never>()

    var token: VOToken.Value? {
        didSet {
            if let token {
                fileClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
                taskClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
                storageClient = .init(
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

    // MARK: - Fetch

    private func fetchFile() async throws -> VOFile.Entity? {
        guard let file else { return nil }
        return try await fileClient?.fetch(file.id)
    }

    func fetchFile() {
        var folder: VOFile.Entity?
        withErrorHandling {
            folder = try await self.fetchFile()
            return true
        } before: {
            self.fileIsLoading = true
        } success: {
            self.file = folder
        } failure: { message in
            self.fileError = message
        } anyways: {
            self.fileIsLoading = false
        }
    }

    private func fetchProbe(_ id: String, size: Int = Constants.pageSize) async throws -> VOFile.Probe? {
        try await fileClient?.fetchProbe(id, options: .init(size: size))
    }

    private func fetchList(_ id: String, page: Int = 1, size: Int = Constants.pageSize) async throws -> VOFile.List? {
        try await fileClient?.fetchList(id, options: .init(query: query, page: page, size: size))
    }

    func fetchNextPage(replace: Bool = false) {
        guard let file else { return }
        guard !entitiesIsLoading else { return }

        var nextPage = -1
        var list: VOFile.List?

        withErrorHandling {
            if let list = self.list {
                let probe = try await self.fetchProbe(file.id, size: Constants.pageSize)
                if let probe {
                    self.list = .init(
                        data: list.data,
                        totalPages: probe.totalPages,
                        totalElements: probe.totalElements,
                        page: list.page,
                        size: list.size,
                        query: list.query
                    )
                }
            }
            if !self.hasNextPage() { return false }
            nextPage = self.nextPage()
            list = try await self.fetchList(file.id, page: nextPage)
            return true
        } before: {
            self.entitiesIsLoading = true
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
            self.entitiesError = message
        } anyways: {
            self.entitiesIsLoading = false
        }
    }

    private func fetchTaskCount() async throws -> Int? {
        try await taskClient?.fetchCount()
    }

    func fetchTaskCount() {
        var taskCount: Int?
        withErrorHandling {
            taskCount = try await self.fetchTaskCount()
            return true
        } before: {
            self.taskCountIsLoading = true
        } success: {
            self.taskCount = taskCount
        } failure: { message in
            self.taskCountError = message
        } anyways: {
            self.taskCountIsLoading = false
        }
    }

    private func fetchStorageUsage() async throws -> VOStorage.Usage? {
        guard let file else { return nil }
        return try await storageClient?.fetchFileUsage(file.id)
    }

    func fetchStorageUsage() {
        var storageUsage: VOStorage.Usage?
        withErrorHandling {
            storageUsage = try await self.fetchStorageUsage()
            return true
        } before: {
            self.storageUsageIsLoading = true
        } success: {
            self.storageUsage = storageUsage
        } failure: { message in
            self.storageUsageError = message
        } anyways: {
            self.storageUsageIsLoading = false
        }
    }

    private func fetchItemCount() async throws -> Int? {
        guard let file else { return nil }
        return try await fileClient?.fetchCount(file.id)
    }

    func fetchItemCount() {
        var itemCount: Int?
        withErrorHandling {
            itemCount = try await self.fetchItemCount()
            return true
        } before: {
            self.itemCountIsLoading = true
        } success: {
            self.itemCount = itemCount
        } failure: { message in
            self.itemCountError = message
        } anyways: {
            self.itemCountIsLoading = false
        }
    }

    // MARK: - Update

    func createFolder(name: String, workspaceID: String, parentID: String) async throws -> VOFile.Entity? {
        try await fileClient?.createFolder(.init(workspaceID: workspaceID, parentID: parentID, name: name))
    }

    func patchName(_ id: String, name: String) async throws -> VOFile.Entity? {
        try await fileClient?.patchName(id, options: .init(name: name))
    }

    func copy(_ ids: [String], to targetID: String) async throws -> VOFile.CopyResult? {
        try await fileClient?.copy(.init(sourceIDs: ids, targetID: targetID))
    }

    func move(_ ids: [String], to targetID: String) async throws -> VOFile.MoveResult? {
        try await fileClient?.move(.init(sourceIDs: ids, targetID: targetID))
    }

    func delete(_ ids: [String]) async throws -> VOFile.DeleteResult? {
        try await fileClient?.delete(.init(ids: ids))
    }

    func upload(_ url: URL, workspaceID: String) async throws -> VOFile.Entity? {
        guard let file else { return nil }
        if let data = try? Data(contentsOf: url) {
            return try await fileClient?.createFile(.init(
                workspaceID: workspaceID,
                parentID: file.id,
                name: url.lastPathComponent,
                data: data
            ))
        }
        return nil
    }

    // MARK: - URL

    func urlForThumbnail(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForThumbnail(id, fileExtension: fileExtension)
    }

    func urlForPreview(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForPreview(id, fileExtension: fileExtension)
    }

    func urlForOriginal(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForOriginal(id, fileExtension: fileExtension)
    }

    // MARK: - Entities

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

    // MARK: - Paging

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

    func isEntityThreshold(_ id: String) -> Bool {
        if let entities {
            let threashold = Constants.pageSize / 2
            if entities.count >= threashold,
               entities.firstIndex(where: { $0.id == id }) == entities.count - threashold {
                return true
            } else {
                return id == entities.last?.id
            }
        }
        return false
    }

    func isLastPage() -> Bool {
        if let list {
            return list.page == list.totalPages
        }
        return false
    }

    // MARK: - Timer

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if let current = self.file {
                Task {
                    var size = Constants.pageSize
                    if let list = self.list {
                        size = Constants.pageSize * list.page
                    }
                    let list = try await self.fetchList(current.id, page: 1, size: size)
                    if let list {
                        DispatchQueue.main.async {
                            self.entities = list.data
                        }
                    }
                }
            }
            if self.file != nil {
                Task {
                    let file = try await self.fetchFile()
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

    // MARK: - Misc

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

    func isInfoAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.viewer)
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

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 50
        static let userDefaultViewModeKey = "com.voltaserve.files.viewMode"
    }
}
