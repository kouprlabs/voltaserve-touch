// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import XCTest

@testable import VoltaserveCore

final class SnapshotsTests: XCTestCase {
    var factory: DisposableFactory?

    func testFetchList() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.snapshot

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))
        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data("Test Content".utf8)
            ))

        // Create snapshots by patching the existing file
        for index in 0..<5 {
            _ = try await factory.client.file.patch(
                file.id,
                options: .init(data: Data("Another Test Content \(index)".utf8), name: file.name)
            )
        }

        // Test we receive a snapshot list
        for index in 1..<3 {
            let page = try await client.fetchList(.init(fileID: file.id, page: index, size: 3))
            XCTAssertEqual(page.page, index)
            XCTAssertEqual(page.size, 3)
            XCTAssertEqual(page.totalElements, 6)
            XCTAssertEqual(page.totalPages, 2)
        }
    }

    func testFetchLanguages() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.snapshot

        let languages = try await client.fetchLanguages()
        XCTAssertFalse(languages.isEmpty)
    }

    func testTextFlow() async throws {
        try await checkDocumentFlow(forResource: "document", withExtension: "txt")
    }

    func testPDFFlow() async throws {
        try await checkDocumentFlow(forResource: "document", withExtension: "pdf")
    }

    func testOfficeFlow() async throws {
        try await checkDocumentFlow(forResource: "document", withExtension: "odt")
    }

    func testJPEGFlow() async throws {
        try await checkImageFlow(
            forResource: "image",
            withExtension: "jpg",
            previewExtension: "jpg",
            thumbnailExtension: "jpg",
            width: 1920,
            height: 1192
        )
    }

    func testPNGFlow() async throws {
        try await checkImageFlow(
            forResource: "image",
            withExtension: "png",
            previewExtension: "png",
            thumbnailExtension: "png",
            width: 1920,
            height: 1192
        )
    }

    func testTIFFFlow() async throws {
        try await checkImageFlow(
            forResource: "image",
            withExtension: "tiff",
            previewExtension: "jpg",
            thumbnailExtension: "jpg",
            width: 1920,
            height: 1192
        )
    }

    func testWebPFlow() async throws {
        try await checkImageFlow(
            forResource: "image",
            withExtension: "webp",
            previewExtension: "webp",
            thumbnailExtension: "webp",
            width: 1920,
            height: 1192
        )
    }

    func testVideoFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let url = getResourceURL(forResource: "video", withExtension: "mp4")!
        let data = try Data(contentsOf: url)
        var file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: url.lastPathComponent,
                data: data
            ))

        // Test original is valid
        XCTAssertNotNil(file.snapshot)
        XCTAssertEqual(file.snapshot!.original.fileExtension, ".mp4")
        XCTAssertEqual(file.snapshot!.original.size, data.count)

        file = try await factory.client.file.wait(file.id)

        // Test preview is nil
        XCTAssertNotNil(file.snapshot!.preview)
        XCTAssertNotNil(file.snapshot!.preview?.fileExtension, ".mp4")
        XCTAssertGreaterThan(file.snapshot!.preview!.size, 0)
        XCTAssertNil(file.snapshot!.preview!.image)
        XCTAssertNil(file.snapshot!.preview!.document)

        // Test thumbnail is valid
        XCTAssertNotNil(file.snapshot!.thumbnail)
        XCTAssertNotNil(file.snapshot!.thumbnail!.image)
        XCTAssertGreaterThan(file.snapshot!.thumbnail!.size, 0)
        XCTAssertEqual(file.snapshot!.thumbnail!.fileExtension, ".png")
        XCTAssertGreaterThan(file.snapshot!.thumbnail!.image!.width, 0)
        XCTAssertGreaterThan(file.snapshot!.thumbnail!.image!.height, 0)
    }

    func checkImageFlow(
        forResource resource: String,
        withExtension fileExtension: String,
        previewExtension: String,
        thumbnailExtension: String,
        width: Int,
        height: Int
    ) async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let url = getResourceURL(forResource: resource, withExtension: fileExtension)!
        let data = try Data(contentsOf: url)
        var file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: url.lastPathComponent,
                data: data
            ))

        // Test original is valid
        XCTAssertNotNil(file.snapshot)
        XCTAssertEqual(file.snapshot!.original.fileExtension, ".\(fileExtension)")
        XCTAssertEqual(file.snapshot!.original.size, data.count)

        file = try await factory.client.file.wait(file.id)

        // Test preview is valid
        XCTAssertNotNil(file.snapshot!.preview)
        XCTAssertNotNil(file.snapshot!.preview?.fileExtension, ".\(previewExtension)")
        XCTAssertGreaterThan(file.snapshot!.preview!.size, 0)
        XCTAssertNotNil(file.snapshot!.preview!.image)
        XCTAssertEqual(file.snapshot!.preview!.image!.width, width)
        XCTAssertEqual(file.snapshot!.preview!.image!.height, height)
        XCTAssertNil(file.snapshot!.preview!.document)

        // Test thumbnail is valid
        XCTAssertNotNil(file.snapshot!.thumbnail)
        XCTAssertNotNil(file.snapshot!.thumbnail!.image)
        XCTAssertGreaterThan(file.snapshot!.thumbnail!.size, 0)
        XCTAssertEqual(file.snapshot!.thumbnail!.fileExtension, ".\(thumbnailExtension)")
        XCTAssertTrue(
            file.snapshot!.thumbnail!.image!.width == 512 || file.snapshot!.thumbnail!.image!.height == 512)
    }

    func checkDocumentFlow(forResource resource: String, withExtension fileExtension: String) async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let url = getResourceURL(forResource: resource, withExtension: fileExtension)!
        let data = try Data(contentsOf: url)
        var file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: url.lastPathComponent,
                data: data
            ))

        // Test original is valid
        XCTAssertNotNil(file.snapshot)
        XCTAssertEqual(file.snapshot!.original.fileExtension, ".\(fileExtension)")
        XCTAssertEqual(file.snapshot!.original.size, data.count)

        file = try await factory.client.file.wait(file.id)

        // Test preview is valid
        XCTAssertNotNil(file.snapshot!.preview)
        XCTAssertNotNil(file.snapshot!.preview?.fileExtension, ".pdf")
        XCTAssertGreaterThan(file.snapshot!.preview!.size, 0)
        XCTAssertNotNil(file.snapshot!.preview!.document)
        XCTAssertNotNil(file.snapshot!.preview!.document!.page)
        XCTAssertEqual(file.snapshot!.preview!.document!.page!.count, 1)
        XCTAssertEqual(
            file.snapshot!.preview!.document!.page!.fileExtension,
            file.snapshot!.preview!.fileExtension
        )
        XCTAssertNil(file.snapshot!.preview!.image)

        // Test thumbnail is valid
        XCTAssertNotNil(file.snapshot!.thumbnail)
        XCTAssertNotNil(file.snapshot!.thumbnail!.image)
        XCTAssertGreaterThan(file.snapshot!.thumbnail!.size, 0)
        XCTAssertEqual(file.snapshot!.thumbnail!.fileExtension, ".png")
        XCTAssertTrue(
            file.snapshot!.thumbnail!.image!.width == 512 || file.snapshot!.thumbnail!.image!.height == 512)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
