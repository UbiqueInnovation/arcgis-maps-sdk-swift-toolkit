import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BookmarksExampleView: View {
    /// The `Map` with predefined bookmarks.
    @State private var map = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
    
    /// The selected bookmark.
    @State private var selection: Bookmark?
    
    /// Indicates if the `Bookmarks` component is shown or not.
    /// - Remark: This allows a developer to control when the `Bookmarks` component is
    /// shown/hidden, whether that be in a group of options or a standalone button.
    @State private var showingBookmarks = false
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .task(id: selection) {
                    if let viewpoint = selection?.viewpoint {
                        await mapViewProxy.setViewpoint(viewpoint)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingBookmarks = true
                        } label: {
                            Label(
                                "Show Bookmarks",
                                systemImage: "bookmark"
                            )
                        }
                        .popover(isPresented: $showingBookmarks) {
                            // Display the `Bookmarks` component with the list of bookmarks in a map.
                            Bookmarks(
                                isPresented: $showingBookmarks,
                                geoModel: map,
                                selection: $selection
                            )
                        }
                    }
                }
        }
    }
}
