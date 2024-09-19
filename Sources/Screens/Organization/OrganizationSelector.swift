import SwiftUI

struct OrganizationSelector: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var organizationStore = OrganizationStore()

    var body: some View {
        List {}
            .onAppear {
                if let token = tokenStore.token {
                    organizationStore.token = token
                }
            }
    }
}
