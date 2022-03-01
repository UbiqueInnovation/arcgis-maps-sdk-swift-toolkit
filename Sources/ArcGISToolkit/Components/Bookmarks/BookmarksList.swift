// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// `BookmarksList` displays a list of selectable bookmarks.
struct BookmarksList: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?

    @Environment(\.verticalSizeClass)
    private var verticalSizeClass: UserInterfaceSizeClass?

    /// A list of bookmarks for display.
    var bookmarks: [Bookmark]

    /// If `true`, the device is in a compact-width or compact-height orientation.
    /// If `false`, the device is in a regular-width and regular-height orientation.
    private var isCompact: Bool {
        horizontalSizeClass == .compact || verticalSizeClass == .compact
    }

    /// The height of the scroll view's content.
    @State
    private var scrollViewContentHeight: CGFloat = .zero

    /// A bookmark that was selected.
    ///
    /// Indicates to the parent that a selection was made.
    @Binding
    var selectedBookmark: Bookmark?

    var body: some View {
        Group {
            if bookmarks.isEmpty {
                Label {
                    Text("No bookmarks")
                } icon: {
                    Image(systemName: "bookmark.slash")
                }
                .foregroundColor(.primary)
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(
                            bookmarks.sorted { $0.name <  $1.name },
                            id: \.viewpoint
                        ) { bookmark in
                            Button {
                                selectedBookmark = bookmark
                            } label: {
                                Text(bookmark.name)
                                    .foregroundColor(.primary)
                            }
                            .padding(4)
                            Divider()
                        }
                    }
                    .padding()
                    .background(
                        GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                scrollViewContentHeight = geometry.size.height
                            }
                            return .clear
                        }
                    )
                }
                .frame(
                    maxHeight: isCompact ? .infinity : scrollViewContentHeight
                )
            }
        }
    }
}
