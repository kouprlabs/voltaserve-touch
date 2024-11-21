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
import VoltaserveCore

struct InsightsCreate: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var insightsStore = InsightsStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isCreating = false
    @State private var language: VOInsights.Language?
    private let fileID: String

    init(_ fileID: String) {
        self.fileID = fileID
    }

    var body: some View {
        NavigationStack {
            if let languages = insightsStore.languages {
                VStack {
                    VStack {
                        ScrollView {
                            // swiftlint:disable:next line_length
                            Text("Select the language to use for collecting insights. During the process, text will be extracted using OCR (optical character recognition), and entities will be scanned using NER (named entity recognition).")
                        }
                        Picker("Language", selection: $language) {
                            ForEach(languages, id: \.id) { language in
                                Text(language.name)
                                    .tag(language)
                            }
                        }
                        .disabled(isCreating)
                        Button {
                            performCreate()
                        } label: {
                            VOButtonLabel("Collect Insights", isLoading: isCreating)
                        }
                        .voPrimaryButton(isDisabled: isCreating || !isValid())
                    }
                    .padding()
                }
                .overlay {
                    RoundedRectangle(cornerRadius: VOMetrics.borderRadius)
                        .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
                }
                .padding(.horizontal)
                .modifierIfPad {
                    $0.padding(.bottom)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Insights")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .disabled(isCreating)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: insightsStore.errorTitle,
            message: insightsStore.errorMessage
        )
        .onAppear {
            insightsStore.fileID = fileID
            if let token = tokenStore.token {
                assignTokenToStores(token)
                onAppearOrChange()
            }
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                onAppearOrChange()
            }
        }
        .onChange(of: insightsStore.languages) { _, newLanguages in
            if let newLanguages {
                language = newLanguages.first(where: { $0.iso6393 == "eng" })
            }
        }
        .presentationDetents([.fraction(0.45)])
        .sync($insightsStore.showError, with: $showError)
    }

    private func performCreate() {
        guard let language else { return }
        isCreating = true
        withErrorHandling {
            _ = try await insightsStore.create(languageID: language.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Creating Insights"
            errorMessage = message
            showError = true
        } anyways: {
            isCreating = false
        }
    }

    private func isValid() -> Bool {
        language != nil
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        insightsStore.fetchLanguages()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        insightsStore.token = token
    }
}
