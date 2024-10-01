import Foundation
import VoltaserveCore

func withErrorHandling(
    _ code: @escaping () async throws -> Bool,
    success: (() -> Void)? = nil,
    failure: @escaping (String) -> Void,
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
                failure(error.userMessage)
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
