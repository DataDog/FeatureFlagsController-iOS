/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import UIKit
import Combine
import SwiftUI
import FeatureFlagsController

final class Example2ViewController: UIViewController {

    override var title: String? {
        get { "Example 2" }
        set {}
    }

    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        
        setUpSquareView()
        setUpExample1Button()
        
        setUpOrientationFeatureFlag()
    }
    
    // MARK: - Views
    
    private let squareView = UIView()

    private func setUpSquareView() {
        view.addSubview(squareView)
        squareView.backgroundColor = .systemTeal
        squareView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            squareView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            squareView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setUpExample1Button() {
        let button = UIButton(type: .system)
        button.setTitle("Example 1", for: .normal)
        button.addTarget(self, action: #selector(openExample1), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private lazy var portraitConstraints = [
        squareView.widthAnchor.constraint(equalToConstant: 150),
        squareView.heightAnchor.constraint(equalToConstant: 250),
    ]

    private lazy var landscapeConstraints = [
        squareView.widthAnchor.constraint(equalToConstant: 250),
        squareView.heightAnchor.constraint(equalToConstant: 150),
    ]

    // MARK: - Feature Flags
    
    private enum Orientation: String, CaseIterable {
        case portrait, landscape
    }
        
    private var cancellables = Set<AnyCancellable>()

    private lazy var orientationFeatureFlag = PickerFeatureFlag(
        title: "Orientation",
        defaultValue: Orientation.portrait,
        group: title,
        style: SegmentedPickerStyle()
    )
    
    private func setUpOrientationFeatureFlag() {
        orientationFeatureFlag
            .register()
            .sink(receiveValue: { [unowned self] orientation in
                switch orientation {
                case .portrait:
                    NSLayoutConstraint.deactivate(self.landscapeConstraints)
                    NSLayoutConstraint.activate(self.portraitConstraints)
                case .landscape:
                    NSLayoutConstraint.deactivate(self.portraitConstraints)
                    NSLayoutConstraint.activate(self.landscapeConstraints)
                }
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc
    private func openExample1() {
        navigationController?.pushViewController(Example1ViewController(), animated: true)
    }

}
