import Combine
import SwiftUI
import Voltaserve

struct GroupMembers: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var membersStore: GroupMembersStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showAddMember = false
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false
    private let group: VOGroup.Entity

    init(_ group: VOGroup.Entity) {
        self.group = group
    }

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
                    membersStore.clear()
                    fetchList()
                }
                .onChange(of: searchText) { searchPublisher.send($1) }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAddMember = true
                        } label: {
                            Label("Add Member", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    GroupSettings()
                }
                .sheet(isPresented: $showAddMember) {
                    Text("Add Member")
                }
                .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                    Button(VOTextConstants.errorAlertButtonLabel) {}
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { membersStore.query = $0 }
                .store(in: &cancellables)
            groupStore.current = group
            if let token = authStore.token {
                onAppearOrChange(token)
            }
        }
        .onDisappear {
            membersStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                onAppearOrChange(newToken)
            }
        }
        .onChange(of: membersStore.query) {
            membersStore.entities = nil
            membersStore.list = nil
            fetchList()
        }
    }

    func onAppearOrChange(_ token: VOToken.Value) {
        membersStore.token = token
        groupStore.token = token
        membersStore.clear()
        fetchList()
        membersStore.startTimer(group.id)
    }

    func onListItemAppear(_ id: String) {
        if membersStore.isLast(id) {
            fetchList()
        }
    }

    func fetchList() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !membersStore.hasNextPage() { return }
                let list = try await membersStore.fetchList(group.id, page: membersStore.nextPage())
                Task { @MainActor in
                    membersStore.list = list
                    if let list {
                        membersStore.append(list.data)
                    }
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.message
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    showError = true
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroupMembers(VOGroup.Entity.devInstance)
            .navigationTitle(VOGroup.Entity.devInstance.name)
            .environmentObject(AuthStore(VOToken.Value.devInstance))
            .environmentObject(GroupMembersStore())
            .environmentObject(GroupStore())
    }
}
