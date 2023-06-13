// Copyright 2023 Esri.

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

import FormsPlugin

public struct Forms: View {
    @State private var rawJSON: String?
    
    @State private var mapInfo: MapInfo?
    
    private let map: Map
    
    public init(map: Map) {
        self.map = map
    }
    
    struct TextBoxEntry: View {
        @State private var text: String = ""
        
        var title: String
        
        public var body: some View {
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    struct TextAreaEntry: View {
        @State private var text: String = ""
        
        @FocusState var isActive: Bool
        
        public var body: some View {
            TextEditor(text: $text)
                .padding(1.5)
                .border(.gray.opacity(0.2))
                .cornerRadius(5)
                .focused($isActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if isActive {
                            Spacer()
                            Button("Done") {
                                isActive.toggle()
                            }
                        }
                    }
                }
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(mapInfo?.operationalLayers.first?.featureFormDefinition.title ?? "Form Title Unavailable")
                .font(.largeTitle)
            Divider()
            ForEach(mapInfo?.operationalLayers.first?.featureFormDefinition.formElements ?? [], id: \.element?.label) { container in
                if let element = container.element as? FieldFeatureFormElement {
                    Text(element.label)
                        .font(.headline)
                    Text(element.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    switch element.inputType.input {
                    case is TextBoxFeatureFormInput:
                        TextBoxEntry(title: element.hint)
                    case is TextAreaFeatureFormInput:
                        TextAreaEntry()
                    default:
                        Text("Unknown Input Type", bundle: .module, comment: "An error when a form element has an unknown type.")
                    }
                }
            }
        }
        .task {
            try? await map.load()
            rawJSON = map.toJSON()
            
            let decoder = JSONDecoder()
            do {
                mapInfo = try decoder.decode(MapInfo.self, from: self.rawJSON!.data(using: .utf8)!)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
