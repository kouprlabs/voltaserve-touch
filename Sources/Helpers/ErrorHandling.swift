import Foundation
import VoltaserveCore

func withErrorHandling(
    _ code: @escaping () async throws -> Bool,
    before: (() -> Void)? = nil,
    success: (() -> Void)? = nil,
    failure: @escaping (String) -> Void,
    invalidCreditentials: (() -> Void)? = nil,
    anyways: (() -> Void)? = nil
) {
    if let before {
        DispatchQueue.main.async {
            before()
        }
    }
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

func withErrorHandling(
    delaySeconds: Double = 0,
    _ code: @escaping () async throws -> Bool,
    before: (() -> Void)? = nil,
    success: (() -> Void)? = nil,
    failure: @escaping (String) -> Void,
    invalidCreditentials: (() -> Void)? = nil,
    anyways: (() -> Void)? = nil
) {
    Timer.scheduledTimer(withTimeInterval: delaySeconds, repeats: false) { _ in
        withErrorHandling(
            code,
            before: before,
            success: success,
            failure: failure,
            invalidCreditentials: invalidCreditentials,
            anyways: anyways
        )
    }
}
