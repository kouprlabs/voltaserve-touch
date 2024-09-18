import Combine
import SwiftUI
import VoltaserveCore

struct GroupMembers: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var membersStore: GroupMembersStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAddMember = false
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false

    var body: some View {
        VStack {
            if let entities = membersStore.entities {
                List {
                    ForEach(entities, id: \.id) { member in
                        VOUserRow(member)
                            .onAppear { onListItemAppear(member.id) }
                    }
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .searchable(text: $searchText)
                .refreshable {
                    fetchList(replace: true)
                }
                .onChange(of: searchText) { searchPublisher.send($1) }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAddMember = true
                        } label: {
                            Label("Add Member", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    GroupSettings {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .sheet(isPresented: $showAddMember) {
                    Text("Add Member")
                }
                .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            membersStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink {
                    membersStore.query = $0
                }
                .store(in: &cancellables)
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            membersStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: membersStore.query) {
            fetchList(replace: true)
        }
    }

    private func onAppearOrChange() {
        guard let group = groupStore.current else { return }
        fetchList(replace: true)
        membersStore.startTimer(group.id)
    }

    private func onListItemAppear(_ id: String) {
        if membersStore.isLast(id) {
            fetchList()
        }
    }

    private func fetchList(replace: Bool = false) {
        guard let group = groupStore.current else { return }

        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOUser.List?

        VOErrorResponse.withErrorHandling {
            if !membersStore.hasNextPage() { return false }
            nextPage = membersStore.nextPage()
            list = try await membersStore.fetchList(group.id, page: nextPage)
            return true
        } success: {
            membersStore.list = list
            if let list {
                if replace, nextPage == 1 {
                    membersStore.entities = list.data
                } else {
                    membersStore.append(list.data)
                }
            }
        } failure: { message in
            errorTitle = "Error: Fetching Members"
            errorMessage = message
            showError = true
        } anyways: {
            isLoading = false
        }
    }
}
