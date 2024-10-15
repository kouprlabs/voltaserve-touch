import Combine
import SwiftUI
import VoltaserveCore

struct BrowserList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @StateObject private var browserStore = BrowserStore()
    @State private var tappedItem: VOFile.Entity?
    @State private var showError = false
    @State private var searchText = ""
    private let fileID: String
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?
    private let onDismiss: (() -> Void)?

    init(
        _ fileID: String,
        workspaceStore: WorkspaceStore,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.fileID = fileID
        self.workspaceStore = workspaceStore
        self.confirmLabelText = confirmLabelText
        self.onCompletion = onCompletion
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack {
            if let entities = browserStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { file in
                                NavigationLink {
                                    BrowserList(
                                        file.id,
                                        workspaceStore: workspaceStore,
                                        confirmLabelText: confirmLabelText,
                                        onCompletion: onCompletion
                                    )
                                    .navigationTitle(file.name)
                                } label: {
                                    FileRow(file)
                                }
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            }
                            if browserStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.inset)
                        .searchable(text: $searchText)
                        .onChange(of: browserStore.searchText) {
                            browserStore.searchPublisher.send($1)
                        }
                        .navigationDestination(item: $tappedItem) {
                            Viewer($0)
                        }
                        .voErrorAlert(
                            isPresented: $showError,
                            title: browserStore.errorTitle,
                            message: browserStore.errorMessage
                        )
                    }
                }
                .refreshable {
                    browserStore.fetchList(replace: true)
                }
            } else {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(confirmLabelText ?? "Done") {
                    onCompletion?(fileID)
                }
            }
            if let workspace = workspaceStore.current, fileID == workspace.rootID {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                }
            }
        }
        .onAppear {
            browserStore.fileID = fileID
            if let token = tokenStore.token {
                assignTokensToStores(token)
                startTimers()
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokensToStores(newToken)
                onAppearOrChange()
            }
        }
        .onChange(of: browserStore.query) {
            browserStore.clear()
            browserStore.fetchList()
        }
        .sync($browserStore.searchText, with: $searchText)
        .sync($browserStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        browserStore.fetch()
        browserStore.fetchList(replace: true)
    }

    private func startTimers() {
        browserStore.startTimer()
    }

    private func stopTimers() {
        browserStore.stopTimer()
    }

    private func assignTokensToStores(_ token: VOToken.Value) {
        browserStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if browserStore.isLast(id) {
            browserStore.fetchList()
        }
    }
}
