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

import SwiftUI
import ArcGIS

/// A view which allows selection of sites and facilities represented in a `FloorManager`.
struct SiteSelector: View {
    /// Creates a `SiteSelector`
    /// - Parameter floorFilterViewModel: The view model used by the `SiteSelector`.
    /// - Parameter showSiteSelector: A binding used to dismiss the site selector.
    public init(
        _ floorFilterViewModel: FloorFilterViewModel,
        showSiteSelector: Binding<Bool>
    ) {
        self.viewModel = floorFilterViewModel
        self.showSiteSelector = showSiteSelector
    }
    
    /// The view model used by the `SiteSelector`.
    @ObservedObject
    private var viewModel: FloorFilterViewModel
    
    /// Allows the user to toggle the visibility of the site selector.
    private var showSiteSelector: Binding<Bool>
    
    var body: some View {
        if viewModel.sites.count > 1 && !(viewModel.selectedSite == nil) {
            // Only show site list if there is more than one site
            // and the user has not yet selected a site.
            FloorFilterList(
                "Select a site...",
                sites: viewModel.sites,
                showSiteSelector: showSiteSelector
            )
        } else {
            FloorFilterList(
                "Select a facility...",
                facilities: viewModel.facilities,
                showSiteSelector: showSiteSelector
            )
        }
    }
    
    /// A view displaying either the sites or facilities contained in a `FloorManager`.
    struct FloorFilterList: View {
        private let title: String
        private let sites: [FloorSite]?
        private let facilities: [FloorFacility]?
        
        /// Binding allowing the user to toggle the visibility of the results list.
        private var showSiteSelector: Binding<Bool>
        
        /// Creates a `FloorFilterList`
        /// - Parameters:
        ///   - title: The title of the list.
        ///   - sites: The sites to display.
        ///   - showSiteSelector: A binding used to dismiss the site selector.
        init(
            _ title: String,
            sites: [FloorSite],
            showSiteSelector: Binding<Bool>
        ) {
            self.title = title
            self.sites = sites
            facilities = []
            self.showSiteSelector = showSiteSelector
        }
        
        init(
            _ title: String,
            facilities: [FloorFacility],
            showSiteSelector: Binding<Bool>
        ) {
            self.title = title
            self.facilities = facilities
            sites = nil
            self.showSiteSelector = showSiteSelector
        }
        
        var body: some View {
            LazyVStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .bold()
                    Spacer()
                    Button {
                        showSiteSelector.wrappedValue.toggle()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                Rectangle()
                    .frame(height:1)
                    .foregroundColor(.secondary)
                ForEach(sites ?? []) { site in
                    Text(site.name)
                }
                ForEach(facilities ?? []) { facility in
                    Text(facility.name)
                }
            }
            .esriBorder()
        }
    }
}
