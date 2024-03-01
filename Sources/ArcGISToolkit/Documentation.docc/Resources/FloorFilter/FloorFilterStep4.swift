import SwiftUI
import ArcGISToolkit
import ArcGIS

struct FloorFilterExampleView: View {
    let floorFilterAlignment = Alignment.bottomLeading
    
    @State private var isMapLoaded = false
    
    @State private var isNavigating = false
    
    @State private var map = Map(
        item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("b4b599a43a474d33946cf0df526426f5")!
        )
    )
    
    @State private var mapLoadError = false
    
    @State private var viewpoint: Viewpoint? = Viewpoint(
        center: Point(
            x: -117.19496,
            y: 34.05713,
            spatialReference: .wgs84
        ),
        scale: 100_000
    )
    
    var body: some View {
        MapView(map: map, viewpoint: viewpoint)
            .onNavigatingChanged {
                isNavigating = $0
            }
            .onViewpointChanged(kind: .centerAndScale) {
                viewpoint = $0
            }
            .task {
                do {
                    try await map.load()
                    isMapLoaded = true
                } catch {
                    mapLoadError = true
                }
            }
    }
}
