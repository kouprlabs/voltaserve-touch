import Combine
import SwiftUI
import VoltaserveCore

struct BrowserList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var browserStore: BrowserStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var tappedItem: VOFile.Entity?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false
    private let id: String
    private let onCompletion: (() -> Void)?
    private let onDismiss: (() -> Void)?
    private let confirmLabelText: String

    init(
        _ id: String,
        confirmLabelText: String = "Done",
        onCompletion: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.id = id
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
                                        file.id,
                                        confirmLabelText: confirmLabelText,
                                        onCompletion: onCompletion,
                                        onDismiss: onDismiss
                                    )
                                    .navigationTitle(file.name)
                                } label: {
                                    FileRow(file)
                                }
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            }
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.inset)
                        .searchable(text: $searchText)
                        .onChange(of: searchText) { searchPublisher.send($1) }
                        .refreshable {
                            fetchList(replace: true)
                        }
                        .navigationDestination(item: $tappedItem) { FileViewer($0) }
                        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(confirmLabelText) {
                    onCompletion?()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", role: .cancel) {
                    onDismiss?()
                }
            }
        }
        .onAppear {
            browserStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink {
                    browserStore.query = .init(text: $0)
                }
                .store(in: &cancellables)
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            browserStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: browserStore.query) {
            browserStore.clear()
            fetchList()
        }
    }

    private func onAppearOrChange() {
        fetchFile()
        fetchList(replace: true)
        browserStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if browserStore.isLast(id) {
            fetchList()
        }
    }

    private func fetchFile() {
        var file: VOFile.Entity?

        VOErrorResponse.withErrorHandling {
            file = try await browserStore.fetch(id)
            return true
        } success: {
            browserStore.current = file
        } failure: { message in
            errorTitle = "Error: Fetching File"
            errorMessage = message
            showError = true
        }
    }

    private func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOFile.List?

        VOErrorResponse.withErrorHandling {
            if !browserStore.hasNextPage() { return false }
            nextPage = browserStore.nextPage()
            list = try await browserStore.fetchList(id, page: nextPage)
            return true
        } success: {
            browserStore.list = list
            if let list {
                if replace, nextPage == 1 {
                    browserStore.entities = list.data
                } else {
                    browserStore.append(list.data)
                }
            }
        } failure: { message in
            errorTitle = "Error: Fetching Files"
            errorMessage = message
            showError = true
        } anyways: {
            isLoading = false
        }
    }
}
