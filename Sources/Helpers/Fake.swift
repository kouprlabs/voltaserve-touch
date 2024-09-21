import Foundation
import VoltaserveCore

enum Fake {
    static let serverError = VOErrorResponse(
        code: .internalServerError,
        status: 500,
        message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        userMessage: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        moreInfo: "http://voltaserve.com"
    )

    static func serverCall<T>(_ code: @escaping (CheckedContinuation<T, any Error>) -> Void) async throws -> T {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, any Error>) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                code(continuation)
            }
        }
    }

    static func serverCall(_ code: @escaping (CheckedContinuation<Void, any Error>) -> Void) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                code(continuation)
            }
        }
    }
}

extension String {
    func lowercasedAndTrimmed() -> String {
        lowercased().trimmingCharacters(in: .whitespaces)
    }
}
