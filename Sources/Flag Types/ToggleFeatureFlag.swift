/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

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
        Toggle(isOn: valueBinding) {
            Text(title)
        }
    }
    
    public var isEnabled: Bool {
        value
    }
}
