/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import UIKit
import Combine
import FeatureFlagsController

final class Example1ViewController: UIViewController {
                
    override var title: String? {
        get { "Example 1" }
        set {}
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        
        setUpSquareView()
        setUpExample2Button()
        
        setUpColorFeatureFlag()
        setUpRoundedCornersFeatureFlag()
    }
    
    // MARK: - Views
    
    private let squareView = UIView()
    private func setUpSquareView() {
        view.addSubview(squareView)
        squareView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            squareView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            squareView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            squareView.widthAnchor.constraint(equalToConstant: 150),
            squareView.heightAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    private func setUpExample2Button() {
        let button = UIButton(type: .system)
        button.setTitle("Example 2", for: .normal)
        button.addTarget(self, action: #selector(openExample2), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: - Feature Flags
    
    private var cancellables = Set<AnyCancellable>()

    private enum Colors: String, CaseIterable {
        case red, green, blue
    }

    private lazy var colorFeatureFlag = PickerFeatureFlag(
        title: "Color",
        defaultValue: Colors.red,
        group: title
    )
    
    private lazy var roundedCornersFeatureFlag = FeatureFlagsGroup(
        title: "Rounded Corners", group: title,
        first: RemoteToggleFeatureFlag(key: "uses_rounded_corners"),
        second: ToggleFeatureFlag(title: "Rounded Corners", defaultValue: true)
    )
    
    private func setUpColorFeatureFlag() {
        colorFeatureFlag.register()
        .map {
            switch $0 {
            case .red: return UIColor.systemRed
            case .green: return UIColor.systemGreen
            case .blue: return UIColor.systemBlue
            }
        }
        .assign(to: \.backgroundColor, on: squareView)
        .store(in: &cancellables)
    }
    
    private func setUpRoundedCornersFeatureFlag() {
        roundedCornersFeatureFlag.register()
        .map { $0 ? 16 : 0 }
        .assign(to: \.cornerRadius, on: squareView.layer)
        .store(in: &cancellables)
    }
        
    // MARK: - Actions

    @objc
    private func openExample2() {
        navigationController?.pushViewController(Example2ViewController(), animated: true)
    }

}
