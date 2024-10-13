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

    func fetchInfo(_ id: String) async throws -> VOMosaic.Info? {
        try await mosaicClient?.fetchInfo(id)
    }

    func fetchInfo() {
        guard let fileID else { return }
        var info: VOMosaic.Info?

        withErrorHandling {
            info = try await self.fetchInfo(fileID)
            return true
        } success: {
            self.info = info
        } failure: { message in
            self.errorTitle = "Error: Fetching Mosaic Info"
            self.errorMessage = message
            self.showError = true
        }
    }

    func create(_: String) async throws {
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func delete(_: String) async throws {
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if let fileID = self.fileID {
                Task {
                    let info = try await self.fetchInfo(fileID)
                    if let info {
                        DispatchQueue.main.async {
                            self.info = info
                        }
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
