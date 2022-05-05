/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import Foundation
import SwiftUI
import Combine

public struct PickerFeatureFlag<Value, Style: PickerStyle>: FeatureFlagType where
    Value: CaseIterable & Hashable & RawRepresentable,
    Value.RawValue == String,
    Value.AllCases: RandomAccessCollection {
    
    public init(title: String, defaultValue: Value, group: String? = nil, userDefaults: UserDefaults = .featureFlags, style: Style) {
        self.title = title
        self.defaultValue = defaultValue
        self.group = group
        self.userDefaults = userDefaults
        self.style = style
    }
    
    private let style: Style
    public let title: String
    public let defaultValue: Value
    public let group: String?
    private let userDefaults: UserDefaults
    
    public var value: Value {
        get {
            guard let rawValue = userDefaults.object(forKey: id) as? String,
                  let value = Value.init(rawValue: rawValue)
            else {
                return defaultValue
            }
            return value
        }
        nonmutating set {
            userDefaults.set(newValue.rawValue, forKey: id)
        }
    }
       
    public var valuePublisher: AnyPublisher<Value, Never> {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in self.value }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public var view: some View {
        HStack(spacing: 16) {
            Text(title)
            Spacer()
            Picker(selection: valueBinding, label: Text("")) {
                ForEach(Value.allCases, id: \.hashValue) { value in
                    value.makeView()
                }
            }
            .pickerStyle(style)
        }
    }
}

extension PickerFeatureFlag where Style == DefaultPickerStyle {
    public init(title: String, defaultValue: Value, group: String? = nil) {
        self = PickerFeatureFlag(title: title, defaultValue: defaultValue, group: group, style: DefaultPickerStyle())
    }
}

extension RawRepresentable where Self: Hashable, RawValue == String {
    fileprivate func makeView() -> some View {
        Text(String(describing: self)).tag(self)
    }
}


extension FeatureFlagType {
    public static func picker<Value, Style: PickerStyle>(
        title: String, defaultValue: Value, group: String? = nil, userDefaults: UserDefaults = .featureFlags, style: Style
    ) -> Self where Self == PickerFeatureFlag<Value, Style> {
        PickerFeatureFlag(title: title, defaultValue: defaultValue, group: group, userDefaults: userDefaults, style: style)
    }
}

@available(iOS 14, *)
extension FeatureFlag {
    public init<Value, Style: PickerStyle>(
        wrappedValue: Value, title: String, group: String? = nil, userDefaults: UserDefaults = .featureFlags, style: Style
    ) where F == PickerFeatureFlag<Value, Style> {
        self.init(PickerFeatureFlag(title: title, defaultValue: wrappedValue, group: group, userDefaults: userDefaults, style: style))
    }
}
