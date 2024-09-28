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
    var file: VOFile.Entity?

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

    private var fileClient: VOFile?

    func fetch() async throws -> VOFile.Entity? {
        guard let file else { return nil }
        return try await fileClient?.fetch(file.id)
    }

    func fetchUserPermissions(_ id: String) async throws -> [VOFile.UserPermission]? {
        try await fileClient?.fetchUserPermissions(id)
    }

    func fetchUserPermissions() {
        guard let file else { return }
        isLoading = true
        var userPermissions: [VOFile.UserPermission]?
        withErrorHandling {
            userPermissions = try await self.fetchUserPermissions(file.id)
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
        guard let file else { return }
        isLoading = true
        var groupPermissions: [VOFile.GroupPermission]?
        withErrorHandling {
            groupPermissions = try await self.fetchGroupPermissions(file.id)
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

    func grantUserPermission(id _: String, userID _: String, permission: VOPermission.Value) async throws {
        try await Fake.serverCall { continuation in
            if permission == .owner {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func revokeUserPermission(id _: String, userID _: String) async throws {
        guard file != nil else { return }
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func grantGroupPermission(id _: String, groupID _: String, permission: VOPermission.Value) async throws {
        try await Fake.serverCall { continuation in
            if permission == .owner {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func revokeGroupPermission(id _: String, groupID _: String) async throws {
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            guard let file = self.file else { return }
            if self.userPermissions != nil {
                Task {
                    let values = try await self.fetchUserPermissions(file.id)
                    if let values {
                        Task { @MainActor in
                            self.userPermissions = values
                        }
                    }
                }
            }
            if self.groupPermissions != nil {
                Task {
                    let values = try await self.fetchGroupPermissions(file.id)
                    if let values {
                        Task { @MainActor in
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
