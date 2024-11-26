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

class SharingStore: ObservableObject {
    @Published var userPermissions: [VOFile.UserPermission]?
    @Published var userPermissionsIsLoading: Bool = false
    var userPermissionsIsLoadingFirstTime: Bool { userPermissionsIsLoading && userPermissions == nil }
    @Published var userPermissionsError: String?
    @Published var groupPermissions: [VOFile.GroupPermission]?
    @Published var groupPermissionsIsLoading: Bool = false
    var groupPermissionsIsLoadingFirstTime: Bool { groupPermissionsIsLoading && groupPermissions == nil }
    @Published var groupPermissionsError: String?
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

    // MARK: - Fetch

    private func fetch() async throws -> VOFile.Entity? {
        guard let fileID else { return nil }
        return try await fileClient?.fetch(fileID)
    }

    private func fetchUserPermissions(_ id: String) async throws -> [VOFile.UserPermission]? {
        try await fileClient?.fetchUserPermissions(id)
    }

    func fetchUserPermissions() {
        guard let fileID else { return }
        var userPermissions: [VOFile.UserPermission]?

        withErrorHandling {
            userPermissions = try await self.fetchUserPermissions(fileID)
            return true
        } before: {
            self.userPermissionsIsLoading = true
        } success: {
            self.userPermissions = userPermissions
        } failure: { message in
            self.userPermissionsError = message
        } anyways: {
            self.userPermissionsIsLoading = false
        }
    }

    private func fetchGroupPermissions(_ id: String) async throws -> [VOFile.GroupPermission]? {
        try await fileClient?.fetchGroupPermissions(id)
    }

    func fetchGroupPermissions() {
        guard let fileID else { return }
        var groupPermissions: [VOFile.GroupPermission]?

        withErrorHandling {
            groupPermissions = try await self.fetchGroupPermissions(fileID)
            return true
        } before: {
            self.groupPermissionsIsLoading = true
        } success: {
            self.groupPermissions = groupPermissions
        } failure: { message in
            self.groupPermissionsError = message
        } anyways: {
            self.groupPermissionsIsLoading = false
        }
    }

    // MARK: - Update

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

    // MARK: - Timer

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
