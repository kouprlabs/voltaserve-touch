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

@MainActor
// swiftlint:disable:next type_body_length
public class FileStore: ObservableObject {
    @Published public var entities: [VOFile.Entity]?
    @Published public var entitiesIsLoading = false
    public var entitiesIsLoadingFirstTime: Bool { entitiesIsLoading && entities == nil }
    @Published public var entitiesError: String?
    @Published public var taskCount: Int?
    @Published public var taskCountIsLoading = false
    @Published public var taskCountError: String?
    @Published public var storageUsage: VOStorage.Usage?
    @Published public var storageUsageIsLoading = false
    @Published public var storageUsageError: String?
    @Published public var itemCount: Int?
    @Published public var itemCountIsLoading = false
    @Published public var itemCountError: String?
    @Published public var current: VOFile.Entity?
    @Published public var currentIsLoading = false
    @Published public var currentError: String?
    @Published public var query: VOFile.Query?
    @Published public var selection = Set<String>() {
        willSet {
            objectWillChange.send()
        }
    }

    @Published public var renameIsPresented = false
    @Published public var deleteConfirmationIsPresented = false
    @Published public var downloadIsPresented = false
    @Published public var browserForMoveIsPresented = false
    @Published public var browserForCopyIsPresented = false
    @Published public var uploadDocumentPickerIsPresented = false
    @Published public var downloadDocumentPickerIsPresented = false
    @Published public var createFolderIsPresented = false
    @Published public var uploadIsPresented = false
    @Published public var moveIsPresented = false
    @Published public var copyIsPresented = false
    @Published public var sharingIsPresented = false
    @Published public var snapshotsIsPresented = false
    @Published public var tasksIsPresented = false
    @Published public var mosaicIsPresented = false
    @Published public var insightsIsPresented = false
    @Published public var infoIsPresented = false
    @Published public var viewMode: ViewMode = .grid {
        didSet {
            UserDefaults.standard.set(
                viewMode.rawValue,
                forKey: Constants.userDefaultViewModeKey
            )
        }
    }
    @Published public var sortBy: VOFile.SortBy = .dateCreated {
        didSet {
            UserDefaults.standard.set(
                sortBy.rawValue,
                forKey: Constants.userDefaultSortByKey
            )
        }
    }
    @Published public var sortOrder: VOFile.SortOrder = .desc {
        didSet {
            UserDefaults.standard.set(
                sortOrder.rawValue,
                forKey: Constants.userDefaultSortOrderKey
            )
        }
    }
    private var list: VOFile.List?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var fileClient: VOFile?
    private var taskClient: VOTask?
    private var storageClient: VOStorage?
    public let searchPublisher = PassthroughSubject<String, Never>()

    public var session: VOSession.Value? {
        didSet {
            if let session {
                fileClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
                taskClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
                storageClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
            }
        }
    }

    public var selectionFiles: [VOFile.Entity] {
        var files: [VOFile.Entity] = []
        for id in selection {
            let file = entities?.first(where: { $0.id == id })
            if let file {
                files.append(file)
            }
        }
        return files
    }

    public init() {
        if let viewMode = UserDefaults.standard.string(forKey: Constants.userDefaultViewModeKey) {
            self.viewMode = ViewMode(rawValue: viewMode)!
        }
        if let sortBy = UserDefaults.standard.string(forKey: Constants.userDefaultSortByKey) {
            self.sortBy = VOFile.SortBy(rawValue: sortBy)!
        }
        if let sortOrder = UserDefaults.standard.string(forKey: Constants.userDefaultSortOrderKey) {
            self.sortOrder = VOFile.SortOrder(rawValue: sortOrder)!
        }
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                if $0.isEmpty {
                    self.query = nil
                } else {
                    self.query = .init(text: $0)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    public func fetchCurrent() {
        guard let current else { return }
        var file: VOFile.Entity?

        withErrorHandling {
            file = try await self.fileClient?.fetch(current.id)
            return true
        } before: {
            self.currentIsLoading = true
        } success: {
            self.current = file
            self.currentError = nil
        } failure: { message in
            self.currentError = message
        } anyways: {
            self.currentIsLoading = false
        }
    }

    public func fetchNextPage(replace: Bool = false) {
        guard let current else { return }
        guard !entitiesIsLoading else { return }
        var nextPage = -1
        var list: VOFile.List?

        withErrorHandling {
            if let list = self.list {
                let probe = try await self.fileClient?.fetchProbe(
                    current.id,
                    options: .init(size: Constants.pageSize)
                )
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
            list = try await self.fileClient?.fetchList(
                current.id,
                options: .init(
                    query: self.query,
                    page: nextPage,
                    size: Constants.pageSize,
                    sortBy: self.sortBy,
                    sortOrder: self.sortOrder
                ))
            self.entitiesError = nil
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

    public func fetchTaskCount() {
        var taskCount: Int?
        withErrorHandling {
            taskCount = try await self.taskClient?.fetchCount()
            self.taskCountError = nil
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

    public func fetchStorageUsage() {
        guard let current else { return }
        var storageUsage: VOStorage.Usage?

        withErrorHandling {
            storageUsage = try await self.storageClient?.fetchFileUsage(current.id)
            self.storageUsageError = nil
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

    public func fetchItemCount() {
        guard let current else { return }
        var itemCount: Int?

        withErrorHandling {
            itemCount = try await self.fileClient?.fetchCount(current.id)
            self.itemCountError = nil
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

    public func create(_ options: VOFile.CreateFolderOptions) async throws -> VOFile.Entity? {
        try await fileClient?.create(options)
    }

    public func create(_ options: VOFile.CreateFileOptions) async throws -> VOFile.Entity? {
        try await fileClient?.create(options)
    }

    public func patch(_ id: String, options: VOFile.PatchOptions) async throws -> VOFile.Entity? {
        try await fileClient?.patch(id, options: options)
    }

    public func patchName(_ id: String, options: VOFile.PatchNameOptions) async throws -> VOFile.Entity? {
        try await fileClient?.patchName(id, options: options)
    }

    public func copy(_ options: VOFile.CopyOptions) async throws -> VOFile.CopyResult? {
        try await fileClient?.copy(options)
    }

    public func move(_ options: VOFile.MoveOptions) async throws -> VOFile.MoveResult? {
        try await fileClient?.move(options)
    }

    public func delete(_ ids: [String]) async throws -> VOFile.DeleteResult? {
        try await fileClient?.delete(.init(ids: ids))
    }

    // MARK: - Sync

    public func syncEntities() async throws {
        if let current = await self.current, let entities = await self.entities {
            let list = try await self.fileClient?.fetchList(
                current.id,
                options: .init(
                    query: self.query,
                    page: 1,
                    size: entities.count > Constants.pageSize ? entities.count : Constants.pageSize,
                    sortBy: self.sortBy,
                    sortOrder: self.sortOrder
                ))
            if let list {
                await MainActor.run {
                    self.entities = list.data
                    self.entitiesError = nil
                }
            }
        }
    }

    public func syncFile() async throws {
        if let current = await current {
            let file = try await self.fileClient?.fetch(current.id)
            if let file {
                await MainActor.run {
                    self.current = file
                    self.currentError = nil
                }
            }
        }
    }

    public func syncFile(id: String) async throws {
        let file = try await self.fileClient?.fetch(id)
        if let file {
            await MainActor.run {
                let index = entities?.firstIndex(where: { $0.id == id })
                if let index {
                    entities?[index] = file
                }
            }
        }
    }

    public func syncTaskCount() async throws {
        if await taskCount != nil {
            let taskCount = try await taskClient?.fetchCount()
            await MainActor.run {
                self.taskCount = taskCount
                self.taskCountError = nil
            }
        }
    }

    // MARK: - URL

    public func urlForThumbnail(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForThumbnail(id, fileExtension: fileExtension)
    }

    public func urlForPreview(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForPreview(id, fileExtension: fileExtension)
    }

    public func urlForOriginal(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForOriginal(id, fileExtension: fileExtension)
    }

    // MARK: - Entities

    public func append(_ newEntities: [VOFile.Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities where !entities!.contains(where: { $0.id == newEntity.id }) {
            entities!.append(newEntity)
        }
    }

    public func clear() {
        entities = nil
        list = nil
    }

    // MARK: - Pagination

    public func nextPage() -> Int {
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

    public func hasNextPage() -> Bool {
        nextPage() != -1
    }

    public func isEntityThreshold(_ id: String) -> Bool {
        if let entities {
            let threashold = Constants.pageSize / 2
            if entities.count >= threashold,
                entities.firstIndex(where: { $0.id == id }) == entities.count - threashold
            {
                return true
            } else {
                return id == entities.last?.id
            }
        }
        return false
    }

    public func isLastPage() -> Bool {
        if let list {
            return list.page == list.totalPages
        }
        return false
    }

    // MARK: - Timer

    public func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task.detached {
                try await self.syncEntities()
                try await self.syncFile()
                try await self.syncTaskCount()
            }
        }
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Misc

    public func isOwnerInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return
            entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.permission.ge(.owner) }
    }

    public func isEditorInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return
            entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.permission.ge(.editor) }
    }

    public func isViewerInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return
            entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.permission.ge(.viewer) }
    }

    public func isFilesInSelection(_ selection: Set<String>) -> Bool {
        guard let entities else { return false }
        return
            entities
            .filter { selection.contains($0.id) }
            .allSatisfy { $0.type == .file }
    }

    public func isInsightsAuthorized(_ file: VOFile.Entity) -> Bool {
        guard let snapshot = file.snapshot else { return false }
        return file.type == .file && !(file.snapshot?.task?.isPending ?? false)
            && (snapshot.capabilities.entities || snapshot.capabilities.summary || snapshot.intent == .document)
            && ((file.permission.ge(.viewer) && file.snapshot?.capabilities.entities ?? false)
                || file.permission.ge(.editor))
    }

    public func isMosaicAuthorized(_ file: VOFile.Entity) -> Bool {
        guard let snapshot = file.snapshot else { return false }
        guard let fileExtension = snapshot.original.fileExtension else { return false }
        return file.type == .file && !(snapshot.task?.isPending ?? false) && fileExtension.isImage()
            && ((file.permission.ge(.viewer) && file.snapshot?.capabilities.mosaic ?? false)
                || file.permission.ge(.editor))
    }

    public func isSharingAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.owner)
    }

    public func isSharingAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isOwnerInSelection(selection)
    }

    public func isDeleteAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.owner)
    }

    public func isDeleteAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isOwnerInSelection(selection)
    }

    public func isMoveAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.editor)
    }

    public func isMoveAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isEditorInSelection(selection)
    }

    public func isCopyAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.editor)
    }

    public func isCopyAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isEditorInSelection(selection)
    }

    public func isSnapshotsAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.owner)
    }

    public func isUploadAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.editor)
    }

    public func isDownloadAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.viewer)
    }

    public func isDownloadAuthorized(_ selection: Set<String>) -> Bool {
        !selection.isEmpty && isViewerInSelection(selection) && isFilesInSelection(selection)
    }

    public func isRenameAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.editor)
    }

    public func isInfoAuthorized(_ file: VOFile.Entity) -> Bool {
        file.permission.ge(.viewer)
    }

    public func isManagementAuthorized(_ file: VOFile.Entity) -> Bool {
        isSharingAuthorized(file) || isSnapshotsAuthorized(file) || isUploadAuthorized(file)
            || isDownloadAuthorized(file)
    }

    public func isOpenAuthorized(_ file: VOFile.Entity) -> Bool {
        file.type == .file && file.permission.ge(.viewer)
    }

    public func toggleViewMode() {
        viewMode = viewMode == .list ? .grid : .list
    }

    public enum ViewMode: String {
        case list
        case grid
    }

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 50
        static let userDefaultViewModeKey = "com.voltaserve.files.viewMode"
        static let userDefaultSortByKey = "com.voltaserve.files.sortBy"
        static let userDefaultSortOrderKey = "com.voltaserve.files.sortOrder"
    }
}
