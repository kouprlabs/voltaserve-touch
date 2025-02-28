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

struct InsightsCreate: View, ViewDataProvider, LoadStateProvider, TokenDistributing, FormValidatable, ErrorPresentable {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var insightsStore = InsightsStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isCreating = false
    @State private var language: VOSnapshot.Language?
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error {
                    VOErrorMessage(error)
                } else {
                    if let languages = insightsStore.languages {
                        VStack {
                            VStack {
                                ScrollView {
                                    // swift-format-ignore
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
                                    VOButtonLabel("Collect", isLoading: isCreating)
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
                    }
                }
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
        }
        .onAppear {
            insightsStore.file = file
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
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performCreate() {
        guard let language else { return }
        withErrorHandling {
            _ = try await insightsStore.create(language: language.id)
            return true
        } before: {
            isCreating = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isCreating = false
        }
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        insightsStore.languagesIsLoadingFirstTime
    }

    var error: String? {
        insightsStore.languagesError
    }

    // MARK: - ErrorPresentable

    @State var errorIsPresented: Bool = false
    @State var errorMessage: String?

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        insightsStore.fetchLanguages()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        insightsStore.token = token
    }

    // MARK: - FormValidatable

    func isValid() -> Bool {
        language != nil
    }
}
