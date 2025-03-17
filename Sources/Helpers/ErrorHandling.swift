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

func withErrorHandling(
    _ code: @escaping () async throws -> Bool,
    before: (() -> Void)? = nil,
    success: (() -> Void)? = nil,
    failure: @escaping (String) -> Void,
    invalidCredentials: (() -> Void)? = nil,
    anyways: (() -> Void)? = nil
) {
    if let before {
        DispatchQueue.main.async {
            before()
        }
    }
    Task {
        do {
            if try await code() {
                DispatchQueue.main.async {
                    success?()
                    anyways?()
                }
            } else {
                DispatchQueue.main.async {
                    anyways?()
                }
            }
        } catch let error as VOErrorResponse {
            DispatchQueue.main.async {
                if error.code == .invalidCredentials {
                    invalidCredentials?()
                } else {
                    failure(error.userMessage)
                }
                anyways?()
            }
        } catch {
            DispatchQueue.main.async {
                failure("Unexpected error occurred.")
                anyways?()
            }
        }
    }
}

func withErrorHandling(
    delaySeconds: Double = 0,
    _ code: @escaping () async throws -> Bool,
    before: (() -> Void)? = nil,
    success: (() -> Void)? = nil,
    failure: @escaping (String) -> Void,
    invalidCredentials: (() -> Void)? = nil,
    anyways: (() -> Void)? = nil
) {
    Timer.scheduledTimer(withTimeInterval: delaySeconds, repeats: false) { _ in
        withErrorHandling(
            code,
            before: before,
            success: success,
            failure: failure,
            invalidCredentials: invalidCredentials,
            anyways: anyways
        )
    }
}
