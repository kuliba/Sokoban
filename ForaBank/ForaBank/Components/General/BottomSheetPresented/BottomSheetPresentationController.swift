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
    private let multiplier: CGFloat = 0.9

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

    var sizeThatFits: CGSize {

        guard let containerView = containerView,
              let presentedView = presentedView else {
                  return .zero
              }

        return presentedView.sizeThatFits(containerView.frame.size)
    }

    override var frameOfPresentedViewInContainerView: CGRect {

        guard let containerView = containerView,
              let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
                  return .zero
              }

        let height = min(sizeThatFits.height, containerView.frame.height * multiplier)
        let contentHeight: CGFloat = containerView.bounds.height - height
        let topDragOffset: CGFloat = 42

        return CGRect(x: 0,
                      y: contentHeight - topDragOffset + window.safeAreaInsets.bottom,
                      width: containerView.bounds.width,
                      height: height + topDragOffset)
    }

    private func configure() {

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
        topContainerView.addGestureRecognizer(tapDragGestureRecognizer)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: presentedView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: presentedView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: presentedView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 21)
        ])

        NSLayoutConstraint.activate([
            topDragView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 8),
            topDragView.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor),
            topDragView.widthAnchor.constraint(equalToConstant: topDragSize.width),
            topDragView.heightAnchor.constraint(equalToConstant: topDragSize.height)
        ])

        tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
        tapDragGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))

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

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        configure()
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

        updatePresentedView()
    }

    private func updatePresentedView() {

        guard let presentedView = presentedView else {
            return
        }

        presentedView.frame = frameOfPresentedViewInContainerView
    }

    private func presentationControllerShouldDismiss() {

        guard let shouldDismiss = delegate?.presentationControllerShouldDismiss else {
            presentingViewController.dismiss(animated: true)
            return
        }

        if shouldDismiss(self) {
            presentingViewController.dismiss(animated: true)
        }
    }

    private func setTransparencyViews(_ hidden: Bool) {

        dimmingView.alpha = hidden ? 0 : 0.3
        topDragView.alpha = hidden ? 0 : 1
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {

        presentationControllerShouldDismiss()
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {

        switch sender.state {

        case .began:
            
            presentationControllerShouldDismiss()

        case .ended:

            updatePresentedView()

        default:
            break
        }
    }
}
