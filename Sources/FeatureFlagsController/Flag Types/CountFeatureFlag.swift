/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import Foundation
import SwiftUI
import Combine

public struct CountFeatureFlag: FeatureFlagType {
    public init(title: String, range: ClosedRange<Int>, defaultValue: Int, group: String? = nil, userDefaults: UserDefaults = .featureFlags) {
        self.title = title
        self.range = range
        self.defaultValue = defaultValue.bound(by: range)
        self.group = group
        self.userDefaults = userDefaults
    }

    public let title: String
    public let range: ClosedRange<Int>
    public let defaultValue: Int
    public let group: String?

    private let userDefaults: UserDefaults

    public var value: Int {
        get {
            guard
                let value = userDefaults.object(forKey: id) as? NSNumber
            else {
                return defaultValue
            }
            return value.intValue
        }
        nonmutating set {
            userDefaults.set(newValue.bound(by: range), forKey: id)
        }
    }

    public var valuePublisher: AnyPublisher<Int, Never> {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in self.value }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public var view: some View {
        HStack {
            Text(title)
            Spacer()
            Text(
                "\(value)"
            )
            .bold()
            Stepper(
                title, value: valueBinding, in: range
            )
            .labelsHidden()
        }
    }
}

extension FeatureFlagType {
    public static func count(
        title: String, range: ClosedRange<Int>, defaultValue: Int, group: String? = nil, userDefaults: UserDefaults = .featureFlags
    ) -> Self where Self == CountFeatureFlag {
        CountFeatureFlag(title: title, range: range, defaultValue: defaultValue, group: group, userDefaults: userDefaults)
    }
}

@available(iOS 14, *)
extension FeatureFlag {
    public init(
        wrappedValue: F.Value, title: String, range: ClosedRange<Int>, group: String? = nil, userDefaults: UserDefaults = .featureFlags
    ) where F == CountFeatureFlag {
        self.init(CountFeatureFlag(title: title, range: range, defaultValue: wrappedValue, group: group, userDefaults: userDefaults))
    }
}

extension Int {
    fileprivate func bound(by range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(range.lowerBound, self), range.upperBound)
    }
}
