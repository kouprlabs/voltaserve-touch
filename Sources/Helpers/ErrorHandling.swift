import Foundation
import VoltaserveCore

func withErrorHandling(
    _ code: @escaping () async throws -> Bool,
    success: (() -> Void)? = nil,
    failure: @escaping (String) -> Void,
    invalidCreditentials: (() -> Void)? = nil,
    anyways: (() -> Void)? = nil
) {
    Task {
        do {
            if try await code() {
                DispatchQueue.main.async {
                    success?()
                    anyways?()
                }
            } else {
                DispatchQueue.main.async {
                    anyways?()
                }
            }
        } catch let error as VOErrorResponse {
            DispatchQueue.main.async {
                if error.code == .invalidCredentials {
                    invalidCreditentials?()
                } else {
                    failure(error.userMessage)
                }
                anyways?()
            }
        } catch {
            DispatchQueue.main.async {
                failure("Unexpected error occurred.")
                anyways?()
            }
        }
    }
}
