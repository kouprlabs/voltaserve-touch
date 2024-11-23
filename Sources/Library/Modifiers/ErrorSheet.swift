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

struct VOErrorSheet: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    private let isPresented: Binding<Bool>
    private let message: String?

    init(isPresented: Binding<Bool>, message: String?) {
        self.isPresented = isPresented
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isPresented) {
                VStack(spacing: VOMetrics.spacing) {
                    VOErrorMessage(message)
                    Button {
                        isPresented.wrappedValue = false
                    } label: {
                        VOButtonLabel("Dismiss")
                    }
                    .voSecondaryButton(colorScheme: colorScheme)
                }
                .padding()
                .presentationDetents([.fraction(0.25)])
            }
    }
}

extension View {
    func voErrorSheet(isPresented: Binding<Bool>, message: String?) -> some View {
        modifier(VOErrorSheet(isPresented: isPresented, message: message))
    }
}

#Preview {
    @Previewable @State var showError = false
    @Previewable @State var showLongError = false

    VStack(spacing: VOMetrics.spacing) {
        Button("Show Error") {
            showError = true
        }
        Button("Show Long Error") {
            showLongError = true
        }
    }
    .voErrorSheet(
        isPresented: $showError,
        message: "Lorem ipsum dolor sit amet."
    )
    .voErrorSheet(
        isPresented: $showLongError,
        // swiftlint:disable:next line_length
        message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    )
}
