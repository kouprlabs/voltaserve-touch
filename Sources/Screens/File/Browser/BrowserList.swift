import Combine
import SwiftUI
import VoltaserveCore

struct BrowserOverview: View {
    @Environment(\.dismiss) private var dismiss
    private let id: String
    private let workspace: VOWorkspace.Entity
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?

    init(
        _ id: String,
        workspace: VOWorkspace.Entity,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)?
    ) {
        self.id = id
        self.workspace = workspace
        self.onCompletion = onCompletion
        self.confirmLabelText = confirmLabelText
    }

    var body: some View {
        NavigationStack {
            BrowserList(
                workspace.rootID,
                workspace: workspace,
                confirmLabelText: confirmLabelText
            ) { id in
                onCompletion?(id)
                dismiss()
            } onDismiss: {
                dismiss()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(workspace.name)
        }
    }
}

struct BrowserList: View {
    @StateObject private var browserStore = BrowserStore()
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @State var tappedItem: VOFile.Entity?
    private let id: String
    private let workspace: VOWorkspace.Entity
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?
    private let onDismiss: (() -> Void)?

    init(
        _ id: String,
        workspace: VOWorkspace.Entity,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.id = id
        self.workspace = workspace
        self.confirmLabelText = confirmLabelText
        self.onCompletion = onCompletion
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack {
            if let entities = browserStore.entities {
                VStack {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { file in
                                NavigationLink {
                                    BrowserList(
                                        file.id, workspace: workspace,
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
                        .searchable(text: $browserStore.searchText)
                        .onChange(of: browserStore.searchText) {
                            browserStore.searchPublisher.send($1)
                        }
                        .refreshable {
                            browserStore.fetchList(replace: true)
                        }
                        .navigationDestination(item: $tappedItem) {
                            FileViewer($0)
                        }
                        .voErrorAlert(
                            isPresented: $browserStore.showError,
                            title: browserStore.errorTitle,
                            message: browserStore.errorMessage
                        )
                    }
                }
            } else {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(confirmLabelText ?? "Done") {
                    onCompletion?(id)
                }
            }
            if id == workspace.rootID {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                }
            }
        }
        .onAppear {
            if let token = tokenStore.token {
                assignTokensToStores(token)
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
    }

    private func onAppearOrChange() {
        fetchData()
        startTimers()
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
