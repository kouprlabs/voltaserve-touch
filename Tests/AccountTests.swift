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

final class AccountTests: XCTestCase {
    var factory: DisposableFactory?

    func testFetchPasswordRequirements() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.account

        let passwordRequirements = try await client.fetchPasswordRequirements()
        XCTAssertTrue(passwordRequirements.minLength > 0)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
