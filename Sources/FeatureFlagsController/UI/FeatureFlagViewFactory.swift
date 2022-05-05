/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import Foundation
import SwiftUI

internal struct FeatureFlagViewFactory {
    
    let id: String
    let group: String?
    let makeView: () -> AnyView
    
    init<F: FeatureFlagType>(_ flag: F) {
        id = flag.id
        group = flag.group
        makeView = { AnyView(flag.view) }
    }
}
