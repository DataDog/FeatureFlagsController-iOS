// Copyright © Datadog, Inc. All rights reserved.

import SwiftUI

public struct FeatureFlagsView: View {
    
    public init() {}
    
    @ObservedObject
    private var controller: FeatureFlagsController = .shared

    private var groupedFlags: [(String?, [FeatureFlagViewFactory])] {
        var groups: [String?] = []
        var map: [String?: [FeatureFlagViewFactory]] = [:]
        for factory in controller.viewFactories {
            if map.keys.contains(factory.group) == false {
                groups.append(factory.group)
            }
            map[factory.group, default: []].append(factory)
        }
        return groups.map { ($0, map[$0]!) }
    }
    
    public var body: some View {
        Form {
            ForEach(groupedFlags, id: \.0) { groupName, factories in
                Section(header: Text(groupName ?? "")) {
                    ForEach(factories, id: \.id) { factory in
                        factory.makeView()
                    }
                }
            }
        }
        .navigationBarTitle("Feature Flags")
    }
}

struct FeatureFlagsView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureFlagsView()
    }
}
