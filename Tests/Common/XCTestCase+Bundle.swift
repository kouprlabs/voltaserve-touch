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
import XCTest

extension XCTestCase {
    func getResourceURL(forResource resource: String, withExtension fileExtension: String) -> URL? {
        #if os(Linux)
            URL(fileURLWithPath: "Tests/Resources/\(resource).\(fileExtension)")
        #else
            Bundle(
                url: Bundle(for: type(of: self)).url(
                    forResource: "VoltaserveCore_VoltaserveTests",
                    withExtension: "bundle"
                )!)!.url(forResource: resource, withExtension: fileExtension)
        #endif
    }
}
