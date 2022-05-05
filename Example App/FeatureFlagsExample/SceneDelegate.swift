/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2020 Datadog, Inc.
 */

import UIKit

import UIKit
import SwiftUI
import Combine
import FeatureFlagsController

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var cancellables = Set<AnyCancellable>()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        
        let exampleTab = UINavigationController(rootViewController: Example1ViewController())
        exampleTab.tabBarItem = UITabBarItem(title: "UIKit Ex.", image: UIImage(systemName: "eye"), tag: 0)
        

        let featureFlagsTab = UIHostingController(rootView: FeatureFlagsView())
        featureFlagsTab.tabBarItem = UITabBarItem(title: "Feature Flags", image: UIImage(systemName: "slider.horizontal.below.rectangle"), tag: 2)
        
        if #available(iOS 14, *) {
            let swiftUIExampleTab = UINavigationController(rootViewController: UIHostingController(rootView: Example3View()))
            swiftUIExampleTab.navigationBar.prefersLargeTitles = true
            swiftUIExampleTab.tabBarItem = UITabBarItem(title: "SwiftUI Ex.", image: UIImage(systemName: "eye"), tag: 1)
            
            tabBarController.viewControllers = [exampleTab, swiftUIExampleTab, featureFlagsTab]
        } else {
            tabBarController.viewControllers = [exampleTab, featureFlagsTab]
        }
        
        window.rootViewController = tabBarController

        self.window = window
        window.makeKeyAndVisible()
        
        setUpDarkModeFeatureFlag()
    }

    private func setUpDarkModeFeatureFlag() {
        ToggleFeatureFlag(title: "Force Dark Mode", defaultValue: false, group: "System")
            .register()
            .sink { [unowned self] forceDarkMode in
                self.window?.rootViewController?.overrideUserInterfaceStyle = forceDarkMode ? .dark : .unspecified
            }
            .store(in: &cancellables)
    }
}
