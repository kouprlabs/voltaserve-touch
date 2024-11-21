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
import SceneKit

extension SCNNode {
    // Helper function to calculate the bounding box considering all child nodes and transformations
    func boundingBoxRelativeToCurrentObject() -> (SCNVector3, SCNVector3) {
        var minVec: SCNVector3 = SCNVector3Zero
        var maxVec: SCNVector3 = SCNVector3Zero
        var first = true

        enumerateChildNodes { node, _ in
            let (nodeMin, nodeMax) = node.boundingBox

            // Apply node transformation to the bounding box
            let transformedMin = node.convertPosition(nodeMin, to: self)
            let transformedMax = node.convertPosition(nodeMax, to: self)

            if first {
                minVec = transformedMin
                maxVec = transformedMax
                first = false
            } else {
                minVec.x = Swift.min(minVec.x, transformedMin.x)
                minVec.y = Swift.min(minVec.y, transformedMin.y)
                minVec.z = Swift.min(minVec.z, transformedMin.z)
                maxVec.x = Swift.max(maxVec.x, transformedMax.x)
                maxVec.y = Swift.max(maxVec.y, transformedMax.y)
                maxVec.z = Swift.max(maxVec.z, transformedMax.z)
            }
        }

        return (minVec, maxVec)
    }
}
