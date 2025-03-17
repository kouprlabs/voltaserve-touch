// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import XCTest

@testable import VoltaserveCore

final class StorageTests: XCTestCase {
    var factory: DisposableFactory?

    func testFetchAccountUsage() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.storage

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let usage = try await client.fetchAccountUsage()
        XCTAssertGreaterThanOrEqual(usage.maxBytes, workspace.storageCapacity)

        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data("Test Content".utf8)
            ))
        let usageAgain = try await client.fetchAccountUsage()
        XCTAssertGreaterThanOrEqual(usageAgain.percentage, 0)
        XCTAssertGreaterThanOrEqual(usageAgain.bytes, file.snapshot!.original.size)
    }

    func testFetchWorkspaceUsage() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.storage

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let usage = try await client.fetchWorkspaceUsage(workspace.id)
        XCTAssertEqual(usage.bytes, 0)
        XCTAssertEqual(usage.percentage, 0)
        XCTAssertEqual(usage.maxBytes, workspace.storageCapacity)

        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File",
                data: Data("Test Content".utf8)
            ))
        let usageAgain = try await client.fetchWorkspaceUsage(workspace.id)
        XCTAssertEqual(usageAgain.bytes, file.snapshot!.original.size)
    }

    func testFetchFileUsage() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.storage

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))
        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data("Test Content".utf8)
            ))

        let usage = try await client.fetchFileUsage(file.id)
        XCTAssertEqual(usage.bytes, file.snapshot!.original.size)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
