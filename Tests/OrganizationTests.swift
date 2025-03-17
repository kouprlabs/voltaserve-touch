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

final class OrganizationTests: XCTestCase {
    var factory: DisposableFactory?
    var otherFactory: DisposableFactory?

    func testOrganizationFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.organization

        // Create organizations
        var options: [VOOrganization.CreateOptions] = []
        for index in 0..<6 {
            options.append(.init(name: "Test Organization \(index)"))
        }
        var organizations: [VOOrganization.Entity] = []
        for index in 0..<options.count {
            try await organizations.append(factory.organization(options[index]))
        }

        // Test creation
        for index in 0..<organizations.count {
            XCTAssertEqual(organizations[index].name, options[index].name)
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
        let organization = try await client.fetch(organizations[0].id)
        XCTAssertEqual(organization.name, organizations[0].name)

        // Test patch name
        let newName = "New Organization"
        let alpha = try await client.patchName(organization.id, options: .init(name: newName))
        XCTAssertEqual(alpha.name, newName)
        let beta = try await factory.client.organization.fetch(organization.id)
        XCTAssertEqual(beta.name, newName)

        // Test leave
        do {
            try await client.leave(organization.id)
            expectedToFail()
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, .cannotRemoveSoleOwnerOfOrganization)
        } catch {
            invalidError(error)
        }

        // Test delete
        for organization in organizations {
            try await client.delete(organization.id)
        }
        for organization in organizations {
            do {
                _ = try await client.fetch(organization.id)
                expectedToFail()
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, .organizationNotFound)
            } catch {
                invalidError(error)
            }
        }
    }

    func testRemoveMember() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory

        guard let otherFactory = try? await DisposableFactory.withOtherCredentials() else {
            failedToCreateFactory()
            return
        }
        self.otherFactory = otherFactory

        let client = factory.client.organization
        let otherClient = otherFactory.client.organization

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.identityUser.fetch()

        let invitations = try await factory.client.invitation.create(
            .init(
                organizationID: organization.id,
                emails: [otherUser.email]
            ))
        try await otherFactory.client.invitation.accept(invitations.first!.id)
        let organizationAgain = try await otherClient.fetch(organization.id)
        XCTAssertEqual(organizationAgain.id, organization.id)

        _ = try await client.removeMember(organization.id, options: .init(userID: otherUser.id))
        do {
            _ = try await client.fetch(organizationAgain.id)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, .organizationNotFound)
        } catch {
            invalidError(error)
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
        await otherFactory?.dispose()
    }
}
