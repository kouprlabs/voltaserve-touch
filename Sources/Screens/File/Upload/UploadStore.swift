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

public class UploadStore: ObservableObject {
    @Published public var entities: [Entity] = []

    public struct Entity {
        let url: URL
        var progress: Double
        var status: Status
        var message: String

        var id: String {
            url.absoluteString
        }

        var displayID: String {
            "\(id)-\(self.objectCode)"
        }

        var objectCode: Int {
            var builder = Hasher()
            builder.combine(id)
            builder.combine(progress)
            builder.combine(status.rawValue)
            return builder.finalize()
        }

        init(_ url: URL, progress: Double = 0, status: Status = .waiting, message: String = "") {
            self.url = url
            self.progress = progress
            self.status = status
            self.message = message
        }
    }

    public enum Status: String, Codable {
        case waiting
        case running
        case success
        case error
        case cancelled
    }

    public func append(_ newEntities: [Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities
        where !entities.contains(where: { $0.url.absoluteString == newEntity.url.absoluteString }) {
            entities.append(newEntity)
        }
    }

    public func remove(_ url: URL) {
        entities.removeAll(where: { $0.url.absoluteURL == url.absoluteURL })
    }

    public func patch(_ url: URL, status: Status? = nil, progress: Double? = nil, message: String? = nil) {
        if let index = entities.firstIndex(where: { $0.url.absoluteString == url.absoluteString }) {
            if let status {
                entities[index].status = status
            }
            if let progress {
                entities[index].progress = progress
            }
            if let message {
                entities[index].message = message
            }
        }
    }

    public func clear() {
        entities = []
    }
}
