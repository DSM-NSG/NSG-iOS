import UIKit

enum AppRootNavigator {

    static func moveToMain(animated: Bool = true) {
        changeRootViewController(
            to: TabbarViewController(),
            animated: animated
        )
    }

    static func moveToOnboarding(animated: Bool = true) {
        let onboarding = SplashViewController()
        let navigationController = UINavigationController(rootViewController: onboarding)
        changeRootViewController(to: navigationController, animated: animated)
    }

    private static func changeRootViewController(to viewController: UIViewController, animated: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        window.rootViewController = viewController

        guard animated else {
            window.makeKeyAndVisible()
            return
        }

        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
}
