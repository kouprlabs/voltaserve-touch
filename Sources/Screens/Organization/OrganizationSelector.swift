import SwiftUI
import VoltaserveCore

struct OrganizationSelector: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var organizationStore = OrganizationStore()
    @State private var selection: String?
    @State private var showError = false
    @State private var searchText = ""
    private let onCompletion: ((VOOrganization.Entity) -> Void)?

    init(onCompletion: ((VOOrganization.Entity) -> Void)? = nil) {
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationStack {
            if let entities = organizationStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no organizations.")
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
                .searchable(text: $searchText)
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
            isPresented: $showError,
            title: organizationStore.errorTitle,
            message: organizationStore.errorMessage
        )
        .onAppear {
            organizationStore.clear()
            if let token = tokenStore.token {
                assignTokenToStores(token)
                startTimers()
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                onAppearOrChange()
            }
        }
        .onChange(of: organizationStore.query) {
            organizationStore.clear()
            organizationStore.fetchList()
        }
        .sync($organizationStore.showError, with: $showError)
        .sync($organizationStore.searchText, with: $searchText)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        organizationStore.fetchList(replace: true)
    }

    private func startTimers() {
        organizationStore.startTimer()
    }

    private func stopTimers() {
        organizationStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        organizationStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if organizationStore.isLast(id) {
            organizationStore.fetchList()
        }
    }
}
