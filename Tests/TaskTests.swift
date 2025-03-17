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

final class TaskTests: XCTestCase {
    var factory: DisposableFactory?

    func testFetch() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.task

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        // Here we intentionally create a file that fails the conversion so the task is not quickly deleted
        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.jpg",
                data: Data("Test Content".utf8)
            ))

        let user = try await factory.client.identityUser.fetch()

        let task = try await client.fetch(file.snapshot!.task!.id)
        XCTAssertEqual(task.userID, user.id)
    }

    func testFetchList() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.task

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))
        _ = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.jpg",
                data: Data("Test Content".utf8)
            ))

        let list = try await client.fetchList(.init())

        // The reason we do 1 here, is because the tests are running in parallel,
        // so there might be other tasks running
        XCTAssertGreaterThanOrEqual(list.totalElements, 1)
    }

    func testFetchCount() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.task

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))
        _ = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File",
                data: Data("Test Content".utf8)
            ))

        let count = try await client.fetchCount()

        // The reason we do 1 here, is because the tests are running in parallel,
        // so there might be other tasks running
        XCTAssertGreaterThanOrEqual(count, 1)
    }

    func testDismiss() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.task

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
                name: "Test File.jpg",
                data: Data("Test Content".utf8)
            ))

        var task = try await client.fetch(file.snapshot!.task!.id)

        // Wait for the task to stop so we can dismiss it
        repeat {
            task = try await client.fetch(task.id)
            sleep(1)
        } while task.status != .error

        try await client.dismiss(task.id)

        do {
            _ = try await client.fetch(task.id)
            expectedToFail()
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, .taskNotFound)
        } catch {
            invalidError(error)
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
