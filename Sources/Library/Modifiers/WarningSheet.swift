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

struct VOWarningSheet: ViewModifier {
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
                    VOWarningMessage(message)
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
    func voWarningSheet(isPresented: Binding<Bool>, message: String?) -> some View {
        modifier(VOWarningSheet(isPresented: isPresented, message: message))
    }
}

#Preview {
    @Previewable @State var showWarning = false
    @Previewable @State var showLongWarning = false

    VStack(spacing: VOMetrics.spacing) {
        Button("Show Warning") {
            showWarning = true
        }
        Button("Show Long Warning") {
            showLongWarning = true
        }
    }
    .voWarningSheet(
        isPresented: $showWarning,
        message: "Lorem ipsum dolor sit amet."
    )
    .voWarningSheet(
        isPresented: $showLongWarning,
        // swiftlint:disable:next line_length
        message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    )
}
