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
public class SharingStore: ObservableObject {
    @Published public var userPermissions: [VOFile.UserPermission]?
    @Published public var userPermissionsIsLoading = false
    public var userPermissionsIsLoadingFirstTime: Bool { userPermissionsIsLoading && userPermissions == nil }
    @Published public var userPermissionsError: String?
    @Published public var groupPermissions: [VOFile.GroupPermission]?
    @Published public var groupPermissionsIsLoading = false
    public var groupPermissionsIsLoadingFirstTime: Bool { groupPermissionsIsLoading && groupPermissions == nil }
    @Published public var groupPermissionsError: String?
    private var timer: Timer?
    private var fileClient: VOFile?
    public var fileID: String?

    public var session: VOSession.Value? {
        didSet {
            if let session {
                fileClient = VOFile(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
            }
        }
    }

    // MARK: - Fetch

    public func fetchUserPermissions() {
        guard let fileID else { return }
        var userPermissions: [VOFile.UserPermission]?

        withErrorHandling {
            userPermissions = try await self.fileClient?.fetchUserPermissions(fileID)
            return true
        } before: {
            self.userPermissionsIsLoading = true
        } success: {
            self.userPermissions = userPermissions
            self.userPermissionsError = nil
        } failure: { message in
            self.userPermissionsError = message
        } anyways: {
            self.userPermissionsIsLoading = false
        }
    }

    public func fetchGroupPermissions() {
        guard let fileID else { return }
        var groupPermissions: [VOFile.GroupPermission]?

        withErrorHandling {
            groupPermissions = try await self.fileClient?.fetchGroupPermissions(fileID)
            self.groupPermissionsError = nil
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

    public func grantUserPermission(_ options: VOFile.GrantUserPermissionOptions) async throws {
        try await fileClient?.grantUserPermission(options)
    }

    public func revokeUserPermission(_ options: VOFile.RevokeUserPermissionOptions) async throws {
        try await fileClient?.revokeUserPermission(options)
    }

    public func grantGroupPermission(_ options: VOFile.GrantGroupPermissionOptions) async throws {
        try await fileClient?.grantGroupPermission(options)
    }

    public func revokeGroupPermission(_ options: VOFile.RevokeGroupPermissionOptions) async throws {
        try await fileClient?.revokeGroupPermission(options)
    }

    // MARK: - Sync

    public func syncUserPermissions() async throws {
        guard let fileID = await self.fileID else { return }
        if await userPermissions != nil {
            let values = try await fileClient?.fetchUserPermissions(fileID)
            if let values {
                await MainActor.run {
                    self.userPermissions = values
                    self.userPermissionsError = nil
                }
            }
        }
    }

    public func syncGroupPermissions() async throws {
        guard let fileID = await self.fileID else { return }
        if await groupPermissions != nil {
            let values = try await self.fileClient?.fetchGroupPermissions(fileID)
            if let values {
                await MainActor.run {
                    self.groupPermissions = values
                    self.groupPermissionsError = nil
                }
            }
        }
    }

    // MARK: - Timer

    public func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task.detached {
                try await self.syncUserPermissions()
                try await self.syncGroupPermissions()
            }
        }
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
