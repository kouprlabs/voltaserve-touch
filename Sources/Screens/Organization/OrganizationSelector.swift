import SwiftUI
import VoltaserveCore

struct OrganizationSelector: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var organizationStore = OrganizationStore()
    @State private var selection: String?
    private let onCompletion: ((VOOrganization.Entity) -> Void)?

    init(onCompletion: ((VOOrganization.Entity) -> Void)? = nil) {
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationStack {
            if let entities = organizationStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List(selection: $selection) {
                            ForEach(entities, id: \.id) { organization in
                                Button {
                                    dismiss()
                                    onCompletion?(organization)
                                } label: {
                                    OrganizationRow(organization)
                                        .onAppear {
                                            onListItemAppear(organization.id)
                                        }
                                }
                            }
                            if organizationStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Select Organization")
                .searchable(text: $organizationStore.searchText)
                .refreshable {
                    organizationStore.fetchList(replace: true)
                }
                .onChange(of: organizationStore.searchText) {
                    organizationStore.searchPublisher.send($1)
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $organizationStore.showError,
            title: organizationStore.errorTitle,
            message: organizationStore.errorMessage
        )
        .onAppear {
            organizationStore.clear()
            if let token = tokenStore.token {
                organizationStore.token = token
                onAppearOrChange()
            }
        }
        .onDisappear {
            organizationStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                organizationStore.token = newToken
                onAppearOrChange()
            }
        }
        .onChange(of: organizationStore.query) {
            organizationStore.clear()
            organizationStore.fetchList()
        }
    }

    private func onAppearOrChange() {
        organizationStore.fetchList(replace: true)
        organizationStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if organizationStore.isLast(id) {
            organizationStore.fetchList()
        }
    }
}
