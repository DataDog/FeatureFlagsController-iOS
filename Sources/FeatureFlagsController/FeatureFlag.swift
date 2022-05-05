/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import SwiftUI
import Combine

@available(iOS 14, *)
@propertyWrapper
public struct FeatureFlag<F: FeatureFlagType>: DynamicProperty {
    @StateObject private var registration: Registration
    private let featureFlag: F

    public var wrappedValue: F.Value {
        registration.value
    }
    
    public var projectedValue: F {
        featureFlag
    }

    public init(_ featureFlag: F) {
        self.featureFlag = featureFlag
        self._registration = StateObject(wrappedValue: Registration(featureFlag))
    }

    private class Registration: ObservableObject {
        
        @Published var value: F.Value
        
        private var cancellable: AnyCancellable?
        
        init(_ featureFlag: F) {
            value = featureFlag.value
            cancellable = featureFlag.register().sink(receiveValue: { [weak self] newValue in
                self?.value = newValue
            })
        }
    }
}
