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

final class EntityTests: XCTestCase {
    var factory: DisposableFactory?

    func testList() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.entity

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
                data: Data(Constants.text.utf8)
            ))
        _ = try await factory.client.file.wait(file.id)

        let task = try await client.create(file.id, options: .init(language: "eng"))
        _ = try await factory.client.task.wait(task.id)

        let entityList = try await client.fetchList(file.id, options: .init(size: 3))
        XCTAssertEqual(entityList.page, 1)
        XCTAssertLessThanOrEqual(entityList.size, 3)
        XCTAssertFalse(entityList.data.isEmpty)
        XCTAssertGreaterThanOrEqual(entityList.totalElements, 0)
    }

    func testDelete() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.entity
        let fileClient = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))
        var file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data(Constants.text.utf8)
            ))
        _ = try await factory.client.file.wait(file.id)

        var task = try await client.create(file.id, options: .init(language: "eng"))
        _ = try await factory.client.task.wait(task.id)

        file = try await fileClient.fetch(file.id)
        XCTAssertTrue(file.snapshot!.capabilities.entities)

        task = try await client.delete(file.id)
        _ = try await factory.client.task.wait(task.id)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }

    enum Constants {
        // swiftlint:disable line_length
        static let text = """
            William Shakespeare was an English playwright, poet and actor. He is widely regarded as the greatest writer in the English language and the world's pre-eminent dramatist. He is often called England's national poet and the "Bard of Avon" (or simply "the Bard"). His extant works, including collaborations, consist of some 39 plays, 154 sonnets, three long narrative poems and a few other verses, some of uncertain authorship. His plays have been translated into every major living language and are performed more often than those of any other playwright. Shakespeare remains arguably the most influential writer in the English language, and his works continue to be studied and reinterpreted.
            """
        // swiftlint:enable line_length
    }
}
