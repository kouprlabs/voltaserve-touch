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
        var progress: Double = 0
        var status: Status = .waiting

        init(_ url: URL) {
            self.url = url
        }
    }

    public enum Status {
        case waiting
        case running
        case success
        case error
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

    public func remove(url: URL) {
        entities.removeAll(where: { $0.url.absoluteURL == url.absoluteURL })
    }

    public func patch(url: URL, progress: Double) {
        if let index = entities.firstIndex(where: { $0.url.absoluteString == url.absoluteString }) {
            entities[index].progress = progress
        }
    }

    public func patch(url: URL, status: Status) {
        if let index = entities.firstIndex(where: { $0.url.absoluteString == url.absoluteString }) {
            entities[index].status = status
        }
    }
}
