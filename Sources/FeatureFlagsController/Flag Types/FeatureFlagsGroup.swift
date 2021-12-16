/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import Foundation
import SwiftUI
import Combine

public struct FeatureFlagsGroup<First: FeatureFlag, Second: FeatureFlag>: FeatureFlag, View where First.Value == Second.Value {
    
    public init(title: String, group: String? = nil, first: First, second: Second, userDefaults: UserDefaults = .featureFlags) {
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
    
    private let userDefaults: UserDefaults
    
    private var values: [String: Value] {
        [first.id: first.value, second.id: second.value]
    }

    public typealias Value = First.Value
    public var value: Value {
        get { values[activeFeatureFlagID.wrappedValue] ?? first.value }
        nonmutating set { }
    }
        
    public var valuePublisher: AnyPublisher<Value, Never> {
        Publishers.Merge3(
            NotificationCenter.default
                .publisher(for: UserDefaults.didChangeNotification)
                .map { _ in self.activeFeatureFlagID.wrappedValue }
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .map { _ in self.value },
            first.valuePublisher,
            second.valuePublisher
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    public var view: some View {
        self
    }

    public var body: some View {
        NavigationLink(destination: detail) {
            Text(title)
        }
    }
    
    @State var refreshCount: Int = 0
    private var activeFeatureFlagID: Binding<String> {
        Binding {
            userDefaults.string(forKey: id + "_activeFeatureFlagID") ?? first.id
        } set: { newValue in
            userDefaults.set(newValue, forKey: id + "_activeFeatureFlagID")
            refreshCount += 1
        }
    }
    
    var detail: some View {
        Form {
            Section(header: Text("ACTIVE FEATURE FLAG")) {
                Picker("", selection: activeFeatureFlagID) {
                    Text("First").tag(first.id)
                    Text("Second").tag(second.id)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("FIRST FEATURE FLAG")) {
                first.view.opacity(activeFeatureFlagID.wrappedValue == first.id ? 1 : 0.5)
            }
            Section(header: Text("SECOND FEATURE FLAG")) {
                second.view.opacity(activeFeatureFlagID.wrappedValue == second.id ? 1 : 0.5)
            }
        }
        .tag(refreshCount)
        .navigationBarTitle(title)
    }
}
