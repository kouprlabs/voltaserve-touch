// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import PhotosUI
import SwiftUI

struct AccountPhotoPicker: UIViewControllerRepresentable {
    private let onCompletion: (_ data: Data, _ filename: String, _ mimeType: String) -> Void

    public init(onCompletion: @escaping (_ data: Data, _ filename: String, _ mimeType: String) -> Void) {
        self.onCompletion = onCompletion
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: AccountPhotoPicker

        init(parent: AccountPhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first else { return }

            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                guard let image = object as? UIImage else { return }

                var data = image.jpegData(compressionQuality: 0.9) ?? Data()
                if data.count > 3 * 1024 * 1024 {
                    let resizedImage = image.resized(toMaxDimension: 1024)
                    data = resizedImage.jpegData(compressionQuality: 0.8) ?? data
                }

                DispatchQueue.main.async {
                    self.parent.onCompletion(data, UUID().uuidString + ".jpg", "image/jpeg")
                }
            }
        }
    }
}
