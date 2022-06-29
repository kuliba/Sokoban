//
//  BottomSheetHostingController.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 27.06.2022.
//

import SwiftUI

// MARK: - ViewController

class BottomSheetHostingController<Content>: UIHostingController<Content> where Content: View {

    @Binding var isPresented: Bool

    override var modalPresentationCapturesStatusBarAppearance: Bool { get { true } set {} }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    var bottomSheetPresentationController: BottomSheetPresentationController? {
        modalPresentationStyle = .custom
        return presentationController as? BottomSheetPresentationController
    }

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            BottomSheetTransitioningDelegate()
        }
        set {
            self.transitioningDelegate = newValue
        }
    }

    init(rootView: Content, isPresented: Binding<Bool>) {

        _isPresented = isPresented
        super.init(rootView: rootView)
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) { nil }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isBeingDismissed == true else {
            return
        }

        isPresented = false
    }
}
