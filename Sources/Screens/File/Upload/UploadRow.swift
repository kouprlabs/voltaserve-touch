// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI

struct UploadRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let upload: UploadStore.Entity

    public init(_ upload: UploadStore.Entity) {
        self.upload = upload
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacingSm) {
            if upload.status == .running {
                if #available(iOS 18.0, macOS 15.0, *) {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle")
                        .symbolEffect(.rotate, options: .repeat(.continuous))
                        .font(.title2)
                        .foregroundStyle(Color.blue400)
                }
            } else if upload.status == .waiting {
                Image(systemName: "hourglass.circle")
                    .font(.title2)
                    .foregroundStyle(Color.gray400)
            } else if upload.status == .success {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(Color.green400)
            } else if upload.status == .error {
                Image(systemName: "exclamationmark.circle")
                    .font(.title2)
                    .foregroundStyle(Color.red400)
            } else if upload.status == .cancelled {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundStyle(Color.yellow400)
            }
            VStack(alignment: .leading, spacing: VOMetrics.spacingXs) {
                Text(upload.url.lastPathComponent)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if !upload.message.isEmpty {
                    Text(upload.message)
                        .font(.footnote)
                        .foregroundStyle(Color.gray500)
                        .lineLimit(3)
                        .truncationMode(.tail)
                }
                if upload.status == .running {
                    ProgressView(value: upload.progress, total: 100)
                        .progressViewStyle(.linear)
                        .tint(colorScheme == .dark ? .white : .black)
                        .padding(.vertical, VOMetrics.spacingXs)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            List {
                NavigationLink(destination: Color.clear) {
                    UploadRow(.init(URL("http://voltaserve.com/example/file.txt")!))
                }
                NavigationLink(destination: Color.clear) {
                    UploadRow(
                        .init(
                            URL("http://voltaserve.com/example/image.jpg")!,
                            progress: 50,
                            status: .running,
                            message: "Lorem ipsum."
                        )
                    )
                }
                NavigationLink(destination: Color.clear) {
                    UploadRow(
                        .init(
                            URL("http://voltaserve.com/example/image.jpg")!,
                            progress: 100,
                            status: .success,
                            message: "Lorem ipsum."
                        )
                    )
                }
                NavigationLink(destination: Color.clear) {
                    UploadRow(
                        .init(
                            URL("http://voltaserve.com/example/image.jpg")!,
                            progress: 100,
                            status: .error,
                            message: "Lorem ipsum."
                        )
                    )
                }
                NavigationLink(destination: Color.clear) {
                    UploadRow(
                        .init(
                            URL("http://voltaserve.com/example/image.jpg")!,
                            progress: 100,
                            status: .cancelled,
                            message: "Lorem ipsum."
                        )
                    )
                }
            }
        }
    }
}
