//
//  BottomSheetPresentationController.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 27.06.2022.
//

import UIKit

// MARK: - Presentation

final class BottomSheetPresentationController: UIPresentationController {

    private let tapDragGestureRecognizer = UITapGestureRecognizer()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    let panGestureRecognizer = UIPanGestureRecognizer()

    private let topDragSize: CGSize = .init(width: 48, height: 5)
    private let maxHeight: CGFloat = 0.9

    private lazy var dimmingView: UIView = {

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0

        return view
    }()

    private lazy var topDragView: UIView = {

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .init(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        view.layer.cornerRadius = topDragSize.height / 2

        return view
    }()

    private lazy var topContainerView: UIView = {

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.backgroundColor = .white

        return view
    }()

    var cornerRadius: CGFloat = 0 {

        didSet {
            presentedView?.layer.cornerRadius = cornerRadius
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {

        guard let containerView = containerView, let presentedView = presentedView else {
            return .zero
        }

        let containerSize = CGSize(width: containerView.frame.width, height: containerView.frame.height)
        let sizeThatFits = presentedView.sizeThatFits(containerSize)

        let height = min(sizeThatFits.height, containerView.frame.height * maxHeight)
        let contentHeight: CGFloat = containerView.bounds.height - height
        let topDragOffset: CGFloat = 42

        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
            return .zero
        }

        return CGRect(x: 0,
                      y: contentHeight - topDragOffset + window.safeAreaInsets.bottom,
                      width: containerView.bounds.width,
                      height: height + topDragOffset)
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView,
              let presentedView = presentedView else {
                  return
              }

        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.masksToBounds = true

        topContainerView.addSubview(topDragView)

        containerView.addSubview(dimmingView)
        presentedView.addSubview(topContainerView)

        containerView.addGestureRecognizer(panGestureRecognizer)
        dimmingView.addGestureRecognizer(tapGestureRecognizer)

        [dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
         dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
         dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
         dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)]
            .forEach { $0.isActive = true }

        [topContainerView.topAnchor.constraint(equalTo: presentedView.topAnchor),
         topContainerView.leadingAnchor.constraint(equalTo: presentedView.leadingAnchor),
         topContainerView.trailingAnchor.constraint(equalTo: presentedView.trailingAnchor),
         topContainerView.heightAnchor.constraint(equalToConstant: 21)]
            .forEach { $0.isActive = true }

        [topDragView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 8),
         topDragView.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor),
         topDragView.widthAnchor.constraint(equalToConstant: topDragSize.width),
         topDragView.heightAnchor.constraint(equalToConstant: topDragSize.height)]
            .forEach { $0.isActive = true }

        tapDragGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))

        topContainerView.addGestureRecognizer(tapDragGestureRecognizer)

        cornerRadius = 12

        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            presentedView.bringSubviewToFront(topContainerView)
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.setTransparencyViews(false)
            })
        } else {
            self.setTransparencyViews(false)
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        delegate?.presentationControllerWillDismiss?(self)

        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.setTransparencyViews(true)
            })
        } else {
            setTransparencyViews(true)
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        guard completed == true else {
            return
        }

        delegate?.presentationControllerDidDismiss?(self)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    private func setTransparencyViews(_ hidden: Bool) {

        dimmingView.alpha = hidden ? 0 : 0.3
        topDragView.alpha = hidden ? 0 : 1
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {

        guard let shouldDismissSheetMethod = delegate?.presentationControllerShouldDismiss else {
            presentingViewController.dismiss(animated: true)
            return
        }

        if shouldDismissSheetMethod(self) {
            presentingViewController.dismiss(animated: true)
        }
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {

        guard sender.state == .began else {
            return
        }

        guard let shouldDismissSheetMethod = delegate?.presentationControllerShouldDismiss else {
            presentingViewController.dismiss(animated: true)
            return
        }

        if shouldDismissSheetMethod(self) {
            presentingViewController.dismiss(animated: true)
        }
    }
}
