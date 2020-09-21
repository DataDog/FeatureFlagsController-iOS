// Copyright © Datadog, Inc. All rights reserved.

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
        exampleTab.tabBarItem = UITabBarItem(title: "Examples", image: UIImage(systemName: "eye"), tag: 0)
        
        let featureFlagsTab = UIHostingController(rootView: NavigationView { FeatureFlagsView() })
        featureFlagsTab.tabBarItem = UITabBarItem(title: "Feature Flags", image: UIImage(systemName: "slider.horizontal.below.rectangle"), tag: 1)
        
        tabBarController.viewControllers = [exampleTab, featureFlagsTab]
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
