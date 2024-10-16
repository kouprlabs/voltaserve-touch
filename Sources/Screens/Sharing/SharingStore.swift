import Combine
import Foundation
import VoltaserveCore

class SharingStore: ObservableObject {
    @Published var userPermissions: [VOFile.UserPermission]?
    @Published var groupPermissions: [VOFile.GroupPermission]?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    private var timer: Timer?
    private var fileClient: VOFile?
    var fileID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                fileClient = VOFile(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    func fetch() async throws -> VOFile.Entity? {
        guard let fileID else { return nil }
        return try await fileClient?.fetch(fileID)
    }

    func fetchUserPermissions(_ id: String) async throws -> [VOFile.UserPermission]? {
        try await fileClient?.fetchUserPermissions(id)
    }

    func fetchUserPermissions() {
        guard let fileID else { return }
        isLoading = true
        var userPermissions: [VOFile.UserPermission]?

        withErrorHandling {
            userPermissions = try await self.fetchUserPermissions(fileID)
            return true
        } success: {
            self.userPermissions = userPermissions
        } failure: { message in
            self.errorTitle = "Error: Fetching User Permissions"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func fetchGroupPermissions(_ id: String) async throws -> [VOFile.GroupPermission]? {
        try await fileClient?.fetchGroupPermissions(id)
    }

    func fetchGroupPermissions() {
        guard let fileID else { return }
        isLoading = true
        var groupPermissions: [VOFile.GroupPermission]?

        withErrorHandling {
            groupPermissions = try await self.fetchGroupPermissions(fileID)
            return true
        } success: {
            self.groupPermissions = groupPermissions
        } failure: { message in
            self.errorTitle = "Error: Fetching Group Permissions"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func grantUserPermission(ids: [String], userID: String, permission: VOPermission.Value) async throws {
        try await fileClient?.grantUserPermission(.init(ids: ids, userID: userID, permission: permission))
    }

    func revokeUserPermission(id: String, userID: String) async throws {
        try await fileClient?.revokeUserPermission(.init(ids: [id], userID: userID))
    }

    func grantGroupPermission(ids: [String], groupID: String, permission: VOPermission.Value) async throws {
        try await fileClient?.grantGroupPermission(.init(ids: ids, groupID: groupID, permission: permission))
    }

    func revokeGroupPermission(id: String, groupID: String) async throws {
        try await fileClient?.revokeGroupPermission(.init(ids: [id], groupID: groupID))
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            guard let fileID = self.fileID else { return }
            if self.userPermissions != nil {
                Task {
                    let values = try await self.fetchUserPermissions(fileID)
                    if let values {
                        DispatchQueue.main.async {
                            self.userPermissions = values
                        }
                    }
                }
            }
            if self.groupPermissions != nil {
                Task {
                    let values = try await self.fetchGroupPermissions(fileID)
                    if let values {
                        DispatchQueue.main.async {
                            self.groupPermissions = values
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
}
