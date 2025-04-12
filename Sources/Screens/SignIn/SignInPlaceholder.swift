// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI

struct SignInPlaceholder: View {
    @State var serverCreateIsPresented = false
    private let extensions: () -> AnyView

    public init(@ViewBuilder extensions: @escaping () -> AnyView = { AnyView(EmptyView()) }) {
        self.extensions = extensions
    }

    var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
            Button {
                serverCreateIsPresented = true
            } label: {
                VOButtonLabel("New Server", systemImage: "plus")
            }
            .voPrimaryButton(width: VOMetrics.formWidth)
            self.extensions()
        }
        .sheet(isPresented: $serverCreateIsPresented) {
            NavigationView {
                ServerCreate()
            }
        }
    }
}
