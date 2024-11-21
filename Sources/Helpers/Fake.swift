// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Foundation
import VoltaserveCore

enum Fake {
    static let serverError = VOErrorResponse(
        code: .internalServerError,
        status: 500,
        message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        userMessage: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        moreInfo: "http://voltaserve.com"
    )

    static func serverCall<T>(_ code: @escaping (CheckedContinuation<T, any Error>) -> Void) async throws -> T {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, any Error>) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                code(continuation)
            }
        }
    }

    static func serverCall(_ code: @escaping (CheckedContinuation<Void, any Error>) -> Void) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                code(continuation)
            }
        }
    }
}

extension String {
    func lowercasedAndTrimmed() -> String {
        lowercased().trimmingCharacters(in: .whitespaces)
    }
}
