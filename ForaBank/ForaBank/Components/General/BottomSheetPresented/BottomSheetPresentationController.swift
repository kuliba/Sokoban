//
//  BottomSheetPresentationController.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 27.06.2022.
//

import UIKit
import Combine

// MARK: - Presentation

final class BottomSheetPresentationController: UIPresentationController {

    private let tapGestureRecognizer = UITapGestureRecognizer()
    private let tapDragGestureRecognizer = UITapGestureRecognizer()
    let panGestureRecognizer = UIPanGestureRecognizer()
    
    private let keyboardPublisher = KeyboardPublisher()
    private var bindings = Set<AnyCancellable>()

    private let topDragSize: CGSize = .init(width: 48, height: 5)
    private let multiplier: CGFloat = 0.9
    
    private var presentedViewBottomConstraint: NSLayoutConstraint?

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

        guard let containerView = containerView else {
            return .zero
        }

        let height = min(sizeThatFits.height, containerView.frame.height * multiplier)
        let contentHeight: CGFloat = containerView.bounds.height - height

        return CGRect(x: 0,
                      y: contentHeight,
                      width: containerView.bounds.width,
                      height: height)
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
        topContainerView.addGestureRecognizer(panGestureRecognizer)

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
        
        presentedViewBottomConstraint = presentedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)

        tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))
        tapDragGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))

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
    
    private func observeKeyboardPublisher() {
        
        keyboardPublisher.keyboardHeight
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] keyboardHeight in
                
                guard let bottomConstraint = presentedViewBottomConstraint else {
                    return
                }
                
                bottomConstraint.constant = keyboardHeight / 3
                
                UIView.animate(withDuration: 0.25) {
                                        
                    self.presentedView?.setNeedsLayout()
                    self.presentedView?.layoutIfNeeded()
                    
                    self.containerView?.setNeedsLayout()
                    self.containerView?.layoutIfNeeded()
                }
                
            }.store(in: &bindings)
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        configure()
        observeKeyboardPublisher()
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
        setupConstraint()
    }
    
    private func setupConstraint() {
        
        guard let presentedViewBottomConstraint = presentedViewBottomConstraint else {
            return
        }
        
        presentedViewBottomConstraint.isActive = true
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
