// Copyright © Datadog, Inc. All rights reserved.

import Foundation
import SwiftUI

internal struct FeatureFlagViewFactory {
    
    let id: String
    let group: String?
    let makeView: () -> AnyView
    
    init<F: FeatureFlag>(_ flag: F) {
        id = flag.id
        group = flag.group
        makeView = { AnyView(flag.view) }
    }
}
