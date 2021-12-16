/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import Foundation
import Combine
import SwiftUI

internal final class FeatureFlagsController: ObservableObject {
    internal static let shared = FeatureFlagsController()

    private init() {}

    internal func register<F: FeatureFlag>(
        _ flag: F
    ) -> AnyPublisher<F.Value, Never> {
        
        if let publisher = publisher(for: flag) {
            return publisher
        }

        let publisher = flag
            .valuePublisher
            .handleEvents(
                receiveOutput: { _ in self.objectWillChange.send() },
                receiveCancel: { self.removePublisher(for: flag) }
            )
            .share()
            .prepend(flag.value)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        addPublisher(publisher, for: flag)
        
        return publisher
    }
    
    // MARK: - Publishers
    
    @Published
    internal var viewFactories: [FeatureFlagViewFactory] = []

    private var publishers: [String: Any] = [:]

    private func publisher<F: FeatureFlag>(
        for flag: F
    ) -> AnyPublisher<F.Value, Never>? {
        publishers[flag.id] as? AnyPublisher<F.Value, Never>
    }
    
    private func addPublisher<F: FeatureFlag>(
        _ publisher: AnyPublisher<F.Value, Never>,
        for flag: F
    ) {
        if viewFactories.contains(where: { $0.id == flag.id }) == false {
            viewFactories.append(FeatureFlagViewFactory(flag))
        }
        publishers[flag.id] = publisher
    }

    private func removePublisher<F: FeatureFlag>(
        for flag: F
    ) {
        viewFactories.removeAll(where: { $0.id == flag.id })
        publishers.removeValue(forKey: flag.id)
    }
}
