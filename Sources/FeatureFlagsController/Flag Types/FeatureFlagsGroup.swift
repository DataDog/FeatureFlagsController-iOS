/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import Foundation
import SwiftUI
import Combine

public struct FeatureFlagsGroup<First: FeatureFlagType, Second: FeatureFlagType>: FeatureFlagType where First.Value == Second.Value {
    
    public init(title: String, first: First, second: Second, group: String? = nil, userDefaults: UserDefaults = .featureFlags) {
        self.title = title
        self.group = group ?? first.group ?? second.group
        self.first = first
        self.second = second
        self.userDefaults = userDefaults
    }
    
    public let first: First
    public let second: Second
    
    public let title: String
    public let group: String?
    
    fileprivate let userDefaults: UserDefaults
    
    private var values: [String: Value] {
        [first.id: first.value, second.id: second.value]
    }

    private var valuePublishers: [String: AnyPublisher<Value, Never>] {
        [first.id: first.valuePublisher, second.id: second.valuePublisher]
    }
    
    private var activeValuePublisher: AnyPublisher<Value, Never> {
        valuePublishers[activeFeatureFlagID] ?? first.valuePublisher
    }

    public typealias Value = First.Value
    public var value: Value {
        get { values[activeFeatureFlagID] ?? first.value }
        nonmutating set { }
    }
        
    public var valuePublisher: AnyPublisher<Value, Never> {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in self.activeFeatureFlagID }
            .prepend(self.activeFeatureFlagID)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .flatMap { _ in
                self.activeValuePublisher.prepend(self.value)
            }
            .eraseToAnyPublisher()
    }
    
    public var view: some View {
        NavigationLink(destination: FeatureFlagsGroupDetailView(featureFlag: self)) {
            Text(title)
        }
    }
    
    fileprivate var activeFeatureFlagID: String {
        get {
            userDefaults.string(forKey: id + "_activeFeatureFlagID") ?? first.id
        }
        nonmutating set {
            userDefaults.set(newValue, forKey: id + "_activeFeatureFlagID")
        }
    }
    
}

private struct FeatureFlagsGroupDetailView<First: FeatureFlagType, Second: FeatureFlagType>: View where First.Value == Second.Value {
    
    let featureFlag: FeatureFlagsGroup<First, Second>
    
    @State var refreshCount: Int = 0
    
    private var activeFeatureFlagID: Binding<String> {
        Binding {
            featureFlag.activeFeatureFlagID
        } set: { newValue in
            featureFlag.activeFeatureFlagID = newValue
            refreshCount += 1
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("ACTIVE FEATURE FLAG")) {
                Picker("", selection: activeFeatureFlagID) {
                    Text("First").tag(featureFlag.first.id)
                    Text("Second").tag(featureFlag.second.id)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("FIRST FEATURE FLAG")) {
                featureFlag.first.view.opacity(activeFeatureFlagID.wrappedValue == featureFlag.first.id ? 1 : 0.5)
            }
            Section(header: Text("SECOND FEATURE FLAG")) {
                featureFlag.second.view.opacity(activeFeatureFlagID.wrappedValue == featureFlag.second.id ? 1 : 0.5)
            }
        }
        .tag(refreshCount)
        .navigationBarTitle(featureFlag.title)
    }
}

extension FeatureFlagType {
    public static func group<First: FeatureFlagType, Second: FeatureFlagType>(
        title: String, first: First, second: Second, group: String? = nil, userDefaults: UserDefaults = .featureFlags
    ) -> Self where Self == FeatureFlagsGroup<First, Second> {
        FeatureFlagsGroup(title: title, first: first, second: second, group: group, userDefaults: userDefaults)
    }
}

@available(iOS 14, *)
extension FeatureFlag {
    public init<First, Second>(
        title: String, first: First, second: Second, group: String? = nil, userDefaults: UserDefaults = .featureFlags
    ) where F == FeatureFlagsGroup<First, Second> {
        self.init(FeatureFlagsGroup(title: title, first: first, second: second, group: group, userDefaults: userDefaults))
    }
}
