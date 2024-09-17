import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationMembers: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var membersStore: OrganizationMembersStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAddMember = false
    @State private var showSettings = false
    @State private var showError = false
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
                            Label("Add Members", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    OrganizationSettings {
                        presentationMode.wrappedValue.dismiss()
                    }
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
            if authStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            membersStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: membersStore.query) {
            fetchList(replace: true)
        }
    }

    func onAppearOrChange() {
        guard let organization = organizationStore.current else { return }
        fetchList(replace: true)
        membersStore.startTimer(organization.id)
    }

    func onListItemAppear(_ id: String) {
        if membersStore.isLast(id) {
            fetchList()
        }
    }

    func fetchList(replace: Bool = false) {
        guard let organization = organizationStore.current else { return }
        Task {
            if isLoading { return }
            Task { @MainActor in
                isLoading = true
            }
            defer {
                Task { @MainActor in
                    isLoading = false
                }
            }
            do {
                if !membersStore.hasNextPage() { return }
                let nextPage = membersStore.nextPage()
                let list = try await membersStore.fetchList(organization.id, page: nextPage)
                Task { @MainActor in
                    membersStore.list = list
                    if let list {
                        if replace, nextPage == 1 {
                            membersStore.entities = list.data
                        } else {
                            membersStore.append(list.data)
                        }
                    }
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    errorMessage = error.message
                    showError = true
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }
}
