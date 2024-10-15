import Combine
import Foundation
import VoltaserveCore

class MosaicStore: ObservableObject {
    @Published var info: VOMosaic.Info?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    private var mosaicClient: VOMosaic?
    private var timer: Timer?
    var fileID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                mosaicClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    func fetchInfo() async throws -> VOMosaic.Info? {
        guard let fileID else { return nil }
        return try await mosaicClient?.fetchInfo(fileID)
    }

    func fetchInfo() {
        var info: VOMosaic.Info?
        withErrorHandling {
            info = try await self.fetchInfo()
            return true
        } success: {
            self.info = info
        } failure: { message in
            self.errorTitle = "Error: Fetching Mosaic Info"
            self.errorMessage = message
            self.showError = true
        }
    }

    func create() async throws {
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func delete() async throws {
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                let info = try await self.fetchInfo()
                if let info {
                    DispatchQueue.main.async {
                        self.info = info
                    }
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
