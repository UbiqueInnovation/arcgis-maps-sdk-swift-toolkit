import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FeatureFormExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("9f3a674e998f461580006e626611f9ad")!
        )
        return Map(item: portalItem)
    }
    
    @State private var map = makeMap()

    @State private var identifyScreenPoint: CGPoint?
    
    @State private var featureForm: FeatureForm?
    
    @State private var showFeatureForm = false
}
