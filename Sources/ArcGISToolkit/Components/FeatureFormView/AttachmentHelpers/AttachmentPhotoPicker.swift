// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import OSLog
import PhotosUI
import SwiftUI

/// A wrapper that provides either a legacy photo picker or the iOS 16.0+ PhotosPicker.
struct AttachmentPhotoPicker: ViewModifier {
    /// The new attachment data retrieved from the photos picker.
    @Binding var newAttachmentData: Data?
    
    /// A Boolean value indicating whether the photos picker is presented.
    @Binding var photoPickerIsShowing: Bool
    
    /// - WARNING: The iOS 15 picker is not implemented.
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .modifier(
                    PhotoPickerWrapper(
                        newAttachmentData: $newAttachmentData,
                        photoPickerIsShowing: $photoPickerIsShowing
                    )
                )
        } else {
            content
                .sheet(isPresented: $photoPickerIsShowing) {
                    Text("Not Supported")
                }
        }
    }
}

@available(iOS 16.0, *)
/// A wrapper for the iOS 16.0+ PhotosPicker API.
struct PhotoPickerWrapper: ViewModifier {
    /// The item selected in the photos picker.
    @State private var item: PhotosPickerItem?
    
    /// The new attachment data retrieved from the photos picker.
    @Binding var newAttachmentData: Data?
    
    /// A Boolean value indicating whether the photos picker is presented.
    @Binding var photoPickerIsShowing: Bool
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $photoPickerIsShowing,
                selection: $item,
                matching: .any(of: [.images, .not(.livePhotos)])
            )
            .task(id: item) {
                guard let item else { return }
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        print("Photo picker data was empty")
                        return
                    }
                    newAttachmentData = data
                } catch {
                    print("Error importing from photo picker: \(error)")
                }
            }
    }
}
