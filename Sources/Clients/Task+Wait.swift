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

extension VOTask {
    public func wait(_ id: String, sleepSeconds: UInt32 = 1) async throws -> Entity? {
        var task: Entity?
        repeat {
            do {
                task = try await fetch(id)
                if task?.status == .error {
                    if let error = task?.error {
                        throw RuntimeError.message(error)
                    } else {
                        throw RuntimeError.message("Unknown error")
                    }
                }
            } catch let error as VOErrorResponse {
                if error.code == .taskNotFound {
                    return nil
                } else {
                    throw error
                }
            }
            sleep(sleepSeconds)
        } while task?.status == .waiting || task?.status == .running
        return task
    }

    public enum RuntimeError: Error {
        case message(String)
    }
}
