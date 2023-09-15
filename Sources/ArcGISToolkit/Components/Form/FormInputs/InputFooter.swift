// Copyright 2023 Esri
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

import ArcGIS
import SwiftUI

/// A view shown at the bottom of a field element in a form.
struct InputFooter: View {
    /// The form element the footer belongs to.
    let element: FieldFormElement
    
    /// A Boolean value indicating if the form element the footer belongs to is required but a value
    /// is missing.
    let requiredValueMissing: Bool
    
    var body: some View {
        Group {
            if requiredValueMissing {
                Text.required
            } else {
                Text(element.description)
            }
        }
        .font(.footnote)
        .foregroundColor(requiredValueMissing ? .red : .secondary)
    }
}
