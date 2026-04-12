//
//  UIViewController+Keyboard.swift
//  NSG
//
//  Created by Codex on 4/12/26.
//
import UIKit
import SnapKit
import ObjectiveC

private var keyboardObserverStoreKey: UInt8 = 0

private final class KeyboardObserverStore {
    var tokens: [NSObjectProtocol] = []

    deinit {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
    }
}

extension UIViewController {

    func bindKeyboard(to bottomConstraint: Constraint, defaultInset: CGFloat) {
        unbindKeyboard()

        let store = KeyboardObserverStore()
        objc_setAssociatedObject(
            self,
            &keyboardObserverStoreKey,
            store,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        let updateConstraint: (Notification) -> Void = { [weak self] notification in
            guard let self else { return }

            let isHiding = notification.name == UIResponder.keyboardWillHideNotification
            let keyboardInset = isHiding ? 0 : self.keyboardInset(from: notification)
            let targetOffset = -(defaultInset + keyboardInset)

            bottomConstraint.update(offset: targetOffset)
            self.animateKeyboardIfNeeded(with: notification)
        }

        let center = NotificationCenter.default
        store.tokens.append(
            center.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main,
                using: updateConstraint
            )
        )
        store.tokens.append(
            center.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main,
                using: updateConstraint
            )
        )
    }

    func unbindKeyboard() {
        objc_setAssociatedObject(self, &keyboardObserverStoreKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func keyboardInset(from notification: Notification) -> CGFloat {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return 0 }

        let keyboardInView = view.convert(keyboardFrame, from: nil)
        let intersectionHeight = view.bounds.intersection(keyboardInView).height
        return max(0, intersectionHeight - view.safeAreaInsets.bottom)
    }

    private func animateKeyboardIfNeeded(with notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 7
        let curveOptions = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [curveOptions, .beginFromCurrentState],
            animations: { self.view.layoutIfNeeded() }
        )
    }
}
