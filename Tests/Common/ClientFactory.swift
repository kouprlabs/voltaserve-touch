// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import VoltaserveCore

class ClientFactory {
    private let config = Config()
    private let token: TokenFactory
    private var _organization: VOOrganization?
    private var _workspace: VOWorkspace?
    private var _file: VOFile?
    private var _snapshot: VOSnapshot?
    private var _task: VOTask?
    private var _group: VOGroup?
    private var _invitation: VOInvitation?
    private var _storage: VOStorage?
    private var _insights: VOEntity?
    private var _mosaic: VOMosaic?
    private var _user: VOUser?
    private var _identityUser: VOIdentityUser?
    private var _account: VOAccount?

    init(_ token: TokenFactory) async throws {
        self.token = token
    }

    var organization: VOOrganization {
        if _organization == nil {
            _organization = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _organization!
    }

    var workspace: VOWorkspace {
        if _workspace == nil {
            _workspace = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _workspace!
    }

    var file: VOFile {
        if _file == nil {
            _file = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _file!
    }

    var snapshot: VOSnapshot {
        if _snapshot == nil {
            _snapshot = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _snapshot!
    }

    var task: VOTask {
        if _task == nil {
            _task = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _task!
    }

    var group: VOGroup {
        if _group == nil {
            _group = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _group!
    }

    var invitation: VOInvitation {
        if _invitation == nil {
            _invitation = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _invitation!
    }

    var storage: VOStorage {
        if _storage == nil {
            _storage = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _storage!
    }

    var entity: VOEntity {
        if _insights == nil {
            _insights = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _insights!
    }

    var mosaic: VOMosaic {
        if _mosaic == nil {
            _mosaic = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _mosaic!
    }

    var user: VOUser {
        if _user == nil {
            _user = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _user!
    }

    var identityUser: VOIdentityUser {
        if _identityUser == nil {
            _identityUser = .init(
                baseURL: config.idpURL,
                accessToken: token.accessToken
            )
        }
        return _identityUser!
    }

    var account: VOAccount {
        if _account == nil {
            _account = .init(baseURL: config.idpURL)
        }
        return _account!
    }
}
