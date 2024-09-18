import Foundation
import VoltaserveCore

extension VOErrorResponse {
    static func withErrorHandling(
        _ code: @escaping () async throws -> Bool,
        success: (() -> Void)? = nil,
        failure: @escaping (String) -> Void,
        anyways: (() -> Void)? = nil
    ) {
        Task {
            do {
                if try await code() {
                    Task { @MainActor in
                        success?()
                        anyways?()
                    }
                } else {
                    Task { @MainActor in
                        anyways?()
                    }
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    failure(error.userMessage)
                    anyways?()
                }
            } catch {
                Task { @MainActor in
                    failure("Unexpected error occurred.")
                    anyways?()
                }
            }
        }
    }
}
