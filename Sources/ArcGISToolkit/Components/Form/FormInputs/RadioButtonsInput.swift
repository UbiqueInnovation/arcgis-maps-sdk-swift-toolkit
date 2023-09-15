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

struct RadioButtonsInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// The feature form containing the input.
    private var featureForm: FeatureForm?
    
    /// The current date selection.
    @State private var date: Date?
    
    /// A Boolean value indicating whether a new date (or time is being set).
    @State private var isEditing = false
    
    /// A Boolean value indicating whether the date selection was cleared when a value is required.
    @State private var requiredValueMissing = false
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: DateTimePickerFormInput
    
    /// Creates a view for a date (and time if applicable) input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: DateTimePickerFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
    }
    
    var body: some View {
        Group {
            FormElementHeader(element: element)
                .padding([.top], elementPadding)
            
            dateEditor
            
            footer
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            if let date = featureForm?.feature.attributes[element.fieldName] as? Date {
                self.date = date
            }
        }
        .onChange(of: date) { newDate in
            requiredValueMissing = element.isRequired && newDate == nil
            featureForm?.feature.setAttributeValue(newDate, forKey: element.fieldName)
        }
        .onChange(of: model.focusedFieldName) { newFocusedFieldName in
            isEditing = newFocusedFieldName == element.fieldName
        }
    }
    
    /// Controls for modifying the date selection.
    @ViewBuilder var dateEditor: some View {
        dateDisplay
        if isEditing {
            datePicker
                .datePickerStyle(.graphical)
        }
    }
    
    /// Elements for display the date selection.
    /// - Note: Secondary foreground color is used across input views for consistency.
    @ViewBuilder var dateDisplay: some View {
        HStack {
            Text(formattedDate ?? .noValue)
                .foregroundColor(displayColor)
            
            Spacer()
            
            if isEditing {
                todayOrNowButton
            } else if true/*element.editable*/ {
                if date == nil {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                } else {
                    ClearButton { date = nil }
                }
            }
        }
        .padding([.vertical], 1.5)
        .formTextInputStyle()
        .frame(maxWidth: .infinity)
        .onTapGesture {
            withAnimation {
//                guard element.editable else { return }
                if date == nil {
                    if dateRange.contains(.now) {
                        date = .now
                    } else if let min = input.min {
                        date = min
                    } else if let max = input.max {
                        date = max
                    }
                }
                isEditing.toggle()
                model.focusedFieldName = isEditing ? element.fieldName : nil
            }
        }
    }
    
    /// Controls for making a specific date selection.
    @ViewBuilder var datePicker: some View {
        DatePicker(
            selection: Binding($date)!,
            in: dateRange,
            displayedComponents: input.includeTime ? [.date, .hourAndMinute] : [.date]
        ) { }
    }
    
    /// The range of dates available for selection, if applicable.
    var dateRange: ClosedRange<Date> {
        if let min = input.min, let max = input.max {
            return min...max
        } else if let min = input.min {
            return min...Date.distantFuture
        } else if let max = input.max {
            return Date.distantPast...max
        } else {
            return Date.distantPast...Date.distantFuture
        }
    }
    
    /// The color in which to display the selected date.
    var displayColor: Color {
        if date == nil {
            return .secondary
        } else if isEditing {
            return .accentColor
        } else {
            return .primary
        }
    }
    
    /// The message shown below the date editor and viewer.
    @ViewBuilder var footer: some View {
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
    
    /// The human-readable date and time selection.
    var formattedDate: String? {
        if input.includeTime {
            return date?.formatted(.dateTime.day().month().year().hour().minute())
        } else {
            return date?.formatted(.dateTime.day().month().year())
        }
    }
    
    /// The button to set the date to the present time.
    var todayOrNowButton: some View {
        Button {
            date = .now
        } label: {
            input.includeTime ? Text.now : .today
        }
    }
}

private extension Text {
    /// A label for a button to choose the current time and date for a field.
    static var now: Self {
        .init(
            "Now",
            bundle: .toolkitModule,
            comment: "A label for a button to choose the current time and date for a field."
        )
    }
    
    /// A label indicating a required field was left blank.
    static var required: Self {
        .init(
            "Required",
            bundle: .toolkitModule,
            comment: "A label indicating a required field was left blank."
        )
    }
    
    /// A label for a button to choose the current date for a field.
    static var today: Self {
        .init(
            "Today",
            bundle: .toolkitModule,
            comment: "A label for a button to choose the current date for a field."
        )
    }
}
