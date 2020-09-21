// Copyright © Datadog, Inc. All rights reserved.

import Combine
import Foundation
import SwiftUI
import Combine

public protocol FeatureFlag {
    associatedtype Value: Equatable
    associatedtype View: SwiftUI.View
    
    var id: String { get }
    var title: String { get }
    var group: String? { get }
    var value: Value { get nonmutating set }
    var valuePublisher: AnyPublisher<Value, Never> { get }
    
    var view: View { get }
}

extension FeatureFlag {
    public var id: String { featureFlagKey(for: title) }
    public var binding: Binding<Value> {
        Binding {
            self.value
        } set: {
            self.value = $0
        }
    }
    
    public func register() -> AnyPublisher<Value, Never> {
        FeatureFlagsController.shared.register(self)
    }
}

private var preferredUserDefaults: UserDefaults = .featureFlagsSuite

extension UserDefaults {
    public static var featureFlags: UserDefaults {
        get { preferredUserDefaults }
        set { preferredUserDefaults = newValue }
    }
    
    public static var featureFlagsSuite: UserDefaults {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return .standard
        }
        return UserDefaults(suiteName: "\(bundleIdentifier).FeatureFlagsController") ?? .standard
    }
}

private func featureFlagKey(for title: String) -> String {
    let slugifiedTitle = title
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .joined(separator: "-")
    return "FeatureFlag_\(slugifiedTitle)"
}
