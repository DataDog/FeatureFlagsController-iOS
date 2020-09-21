// Copyright © Datadog, Inc. All rights reserved.

import Foundation
import SwiftUI
import Combine

public struct ToggleFeatureFlag: FeatureFlag {
    
    public init(title: String, defaultValue: Bool, group: String? = nil, userDefaults: UserDefaults = .featureFlags) {
        self.title = title
        self.defaultValue = defaultValue
        self.group = group
        self.userDefaults = userDefaults
    }
    
    public let title: String
    public let defaultValue: Bool
    public let group: String?
    
    private let userDefaults: UserDefaults
    
    public var value: Bool {
        get {
            guard
                let value = userDefaults.object(forKey: id) as? NSNumber
            else {
                return defaultValue
            }
            return value.boolValue
        }
        nonmutating set {
            userDefaults.set(newValue, forKey: id)
        }
    }
    
    public var valuePublisher: AnyPublisher<Bool, Never> {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in self.value }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var view: some View {
        Toggle(isOn: binding) {
            Text(title)
        }
    }
    
    public var isEnabled: Bool {
        value
    }
}
