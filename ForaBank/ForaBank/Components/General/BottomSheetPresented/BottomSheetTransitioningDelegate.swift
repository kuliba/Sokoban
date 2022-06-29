//
//  BottomSheetTransitioningDelegate.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 27.06.2022.
//

import UIKit

// MARK: - Delegate

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let presentationController = dismissed.presentationController

        guard let presentationController = presentationController as? BottomSheetPresentationController else {
            return nil
        }

        return BottomSheetDismissed(panGestureRecognizer: presentationController.panGestureRecognizer)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        guard let interactiveTransition = animator as? BottomSheetDismissed,
              interactiveTransition.panGestureRecognizer.state == .began else {
                  return nil
              }

        return interactiveTransition
    }
}

class BottomSheetDismissed: UIPercentDrivenInteractiveTransition {

    private let dismissPercent: CGFloat = 0.3
    private let interactiveDuration = 0.3
    private let immediateDuration = 0.2

    private var initialFrame: CGRect = .zero
    fileprivate let panGestureRecognizer: UIPanGestureRecognizer

    init(panGestureRecognizer: UIPanGestureRecognizer) {

        self.panGestureRecognizer = panGestureRecognizer
        super.init()

        configure()
    }

    private func configure() {

        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
    }

    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        if let viewController = transitionContext.viewController(forKey: .from) {
            initialFrame = transitionContext.initialFrame(for: viewController)
        }

        super.startInteractiveTransition(transitionContext)
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {

        switch sender.state {

        case .changed:
            let translation: CGPoint = sender.translation(in: nil)
            let offset: CGFloat = translation.y / initialFrame.height
            let percentage: CGFloat = max(min(offset, 1), 0)
            update(percentage)

        case .cancelled:
            cancel()
        case .ended:
            percentComplete > dismissPercent ? finish() : cancel()
        default:
            break
        }
    }
}

extension BottomSheetDismissed: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {

        transitionContext?.isInteractive == true ? interactiveDuration : immediateDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let from = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let initialFrame = transitionContext.initialFrame(for: from)
        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {

            from.view.frame = initialFrame.offsetBy(dx: 0, dy: initialFrame.height)

        }, completion: { _ in

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
