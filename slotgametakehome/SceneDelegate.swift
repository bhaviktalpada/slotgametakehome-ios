//
//  SceneDelegate.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import UIKit

/// Scene delegate managing UIWindow presentation, root view controller hierarchy, and landscape geometry request.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    /// Primary application window.
    var window: UIWindow?

    // MARK: - UIScene Lifecycle Process

    /// Configures the window scene, assigns `GameViewController` as the root view controller,
    /// and requests landscape geometry update on iOS 16+.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let gameViewController = GameViewController()
        window.rootViewController = gameViewController
        window.makeKeyAndVisible()
        self.window = window

        // Explicitly request landscape geometry for iPads running iOS 16+
        if #available(iOS 16.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}
