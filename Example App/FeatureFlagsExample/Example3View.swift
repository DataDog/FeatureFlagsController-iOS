/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import SwiftUI
import FeatureFlagsController

@available(iOS 14, *)
struct Example3View: View {
    
    static let trailingIndexFeatureFlag = ToggleFeatureFlag(
        title: "Trailing Index", defaultValue: true, group: "SWIFTUI EXAMPLE"
    )
 
    @FeatureFlag(trailingIndexFeatureFlag) // Either pass an existing, shared, feature flag...
    var trailingIndex
    
    @FeatureFlag(title: "Elements Count", range: 3...10, group: "SWIFTUI EXAMPLE") // ...or declare a new feature flag just for this view
    var elementsCount = 5

    var body: some View {
        List {
            ForEach(Array(1 ... elementsCount), id: \.self) { i in
                if trailingIndex {
                    HStack {
                        Text("Element")
                        Spacer()
                        Text("#\(i)").foregroundColor(.secondary)
                    }
                } else {
                    Text("Element #\(i)")
                }
            }
        }
        .navigationTitle($elementsCount.title + " \(elementsCount)/\($elementsCount.defaultValue)")
    }
}

