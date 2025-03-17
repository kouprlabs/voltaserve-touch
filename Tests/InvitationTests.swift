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

final class InvitationTests: XCTestCase {
    var factory: DisposableFactory?
    var otherFactory: DisposableFactory?

    func testFetchIncoming() async throws {
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

        let client = factory.client.invitation
        let otherClient = otherFactory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.identityUser.fetch()

        _ = try await client.create(.init(organizationID: organization.id, emails: [otherUser.email]))

        let incoming = try await otherClient.fetchIncomingList(.init(organizationID: organization.id))
        XCTAssertEqual(incoming.totalElements, 1)
    }

    func testFetchOutgoing() async throws {
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

        let client = factory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.identityUser.fetch()

        _ = try await client.create(.init(organizationID: organization.id, emails: [otherUser.email]))

        let outgoing = try await client.fetchOutgoingList(.init(organizationID: organization.id))
        XCTAssertEqual(outgoing.totalElements, 1)
    }

    func testDelete() async throws {
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

        let client = factory.client.invitation
        let otherClient = factory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.identityUser.fetch()

        let invitations = try await client.create(
            .init(
                organizationID: organization.id,
                emails: [otherUser.email]
            ))
        try await client.delete(invitations[0].id)
        let outgoing = try await otherClient.fetchIncomingList(.init())
        XCTAssertEqual(outgoing.totalElements, 0)
    }

    func testAccept() async throws {
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

        let client = factory.client.invitation
        let otherClient = otherFactory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.identityUser.fetch()

        let invitations = try await client.create(
            .init(
                organizationID: organization.id,
                emails: [otherUser.email]
            ))

        try await otherClient.accept(invitations.first!.id)
        let organizationMembers = try await factory.client.user.fetchList(.init(organizationID: organization.id))
        XCTAssertTrue(organizationMembers.data.contains(where: { $0.id == otherUser.id }))

        let otherOrganizations = try await otherFactory.client.organization.fetchList(.init())
        XCTAssertTrue(otherOrganizations.data.contains(where: { $0.id == organization.id }))

        let organizationAgain = try await otherFactory.client.organization.fetch(organization.id)
        XCTAssertTrue(organizationAgain.id == organization.id)
    }

    func testDecline() async throws {
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

        let client = factory.client.invitation
        let otherClient = otherFactory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.identityUser.fetch()

        let invitations = try await client.create(
            .init(
                organizationID: organization.id,
                emails: [otherUser.email]
            ))
        try await otherClient.decline(invitations[0].id)

        let incoming = try await otherClient.fetchIncomingList(.init())
        XCTAssertEqual(incoming.totalElements, 0)

        let outgoing = try await client.fetchOutgoingList(.init(organizationID: organization.id))
        XCTAssertEqual(outgoing.totalElements, 1)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
        await otherFactory?.dispose()
    }
}
