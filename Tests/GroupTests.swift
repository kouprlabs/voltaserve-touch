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

final class GroupTests: XCTestCase {
    var factory: DisposableFactory?

    func testGroupFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.group

        let organization = try await factory.organization(.init(name: "Test Organization"))

        // Create groups
        var options: [VOGroup.CreateOptions] = []
        for index in 0..<6 {
            options.append(.init(name: "Test Group \(index)", organizationID: organization.id))
        }
        var groups: [VOGroup.Entity] = []
        for index in 0..<options.count {
            try await groups.append(factory.group(options[index]))
        }

        // Test creation
        for index in 0..<groups.count {
            XCTAssertEqual(groups[index].name, options[index].name)
            XCTAssertEqual(groups[index].organization.id, options[index].organizationID)
        }

        // Test list

        // Page 1
        let page1 = try await client.fetchList(.init(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertGreaterThanOrEqual(page1.totalPages, 2)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        // Page 2
        let page2 = try await client.fetchList(.init(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        // Test fetch
        let group = try await client.fetch(groups[0].id)
        XCTAssertEqual(group.name, groups[0].name)
        XCTAssertEqual(group.organization.id, groups[0].organization.id)

        // Test patch name
        let newName = "New Group"
        let alpha = try await client.patchName(group.id, options: .init(name: newName))
        XCTAssertEqual(alpha.name, newName)
        let beta = try await client.fetch(group.id)
        XCTAssertEqual(beta.name, newName)

        // Test delete
        for group in groups {
            try await client.delete(group.id)
        }
        for group in groups {
            do {
                _ = try await client.fetch(group.id)
                expectedToFail()
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, .groupNotFound)
            } catch {
                invalidError(error)
            }
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
