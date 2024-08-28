import Combine
import Foundation
import Voltaserve

class SignUpStore: ObservableObject {
    @Published var passwordRequirements: VOAccount.PasswordRequirements?

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.passwordRequirements = VOAccount.PasswordRequirements(
                minLength: 8,
                minLowercase: 1,
                minUppercase: 1,
                minNumbers: 1,
                minSymbols: 1
            )
        }
    }
}
