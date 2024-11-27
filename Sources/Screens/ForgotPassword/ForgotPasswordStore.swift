// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import Foundation
import VoltaserveCore

class ForgotPasswordStore: ObservableObject {
    private var accountClient: VOAccount = .init(baseURL: Config.production.idpURL)

    // MARK: - Update

    func sendResetPasswordEmail(_ options: VOAccount.SendResetPasswordEmailOptions) async throws {
        try await accountClient.sendResetPasswordEmail(options)
    }
}
