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

public struct FileRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let file: VOFile.Entity

    public init(_ file: VOFile.Entity) {
        self.file = file
    }

    public var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            if file.type == .file {
                Image(file.iconForFile(colorScheme: colorScheme))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            } else if file.type == .folder {
                Image("icon-folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading) {
                Text(file.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(file.createTime.relativeDate())
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
            }
            Spacer()
            FileAdornments(file)
                .padding(.trailing, VOMetrics.spacingMd)
        }
        .padding(VOMetrics.spacingSm)
    }
}
