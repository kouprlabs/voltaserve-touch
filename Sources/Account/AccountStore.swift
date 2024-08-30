import Foundation
import Voltaserve

class AccountStore: ObservableObject {
    @Published var user: VOUser.Entity?

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.user = .init(
                id: UUID().uuidString,
                username: "anass@koupr.com",
                email: "anass@koupr.com",
                fullName: "Anass Bouassaba",
                createTime: Date().ISO8601Format()
            )
        }
    }

    func update(email: String, fullName: String) async throws {
        try await withCheckedThrowingContinuation { continutation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if let user {
                    self.user = VOUser.Entity(
                        id: user.id,
                        username: user.username,
                        email: email,
                        fullName: fullName,
                        createTime: user.createTime
                    )
                }
                continutation.resume()
            }
        }
    }
}
