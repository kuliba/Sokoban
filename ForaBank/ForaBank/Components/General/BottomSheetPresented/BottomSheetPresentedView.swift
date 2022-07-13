//
//  BottomSheetPresentedView.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 26.06.2022.
//

import SwiftUI

// MARK: - View

extension View {

    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {

        modifier(BottomSheetModifier(isPresented: isPresented, content: content))
    }

    func bottomSheet<Item, Content>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item : Identifiable, Content : View {

        let isShowBottomSheet = Binding {
            item.wrappedValue != nil
        } set: { value in
            if value == false {
                item.wrappedValue = nil
            }
        }

        return bottomSheet(isPresented: isShowBottomSheet, onDismiss: onDismiss) {

            if let unwrapedItem = item.wrappedValue {
                content(unwrapedItem)
                    .padding(.top, 21)
            }
        }
    }

    func present<Content, ViewController>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        viewController: @escaping (Content) -> ViewController) -> some View where Content: View, ViewController: UIHostingController<Content> {

            modifier(BottomSheetPresentModifier(
                isPresented: isPresented,
                content: content,
                viewController: viewController))
        }
}

// MARK: - ViewModifiers

struct BottomSheetModifier<Presented: View>: ViewModifier {

    @Binding var isPresented: Bool
    let content: () -> Presented

    init(isPresented: Binding<Bool>, content: @escaping () -> Presented) {

        _isPresented = isPresented
        self.content = content
    }

    func body(content: Content) -> some View {
        content
            .present(isPresented: $isPresented, content: self.content) { content in

                let viewController = BottomSheetHostingController(
                    rootView: content,
                    isPresented: $isPresented)

                viewController.modalPresentationStyle = .custom

                return viewController
            }
    }
}

struct BottomSheetPresentModifier<Presented, Controller>: ViewModifier where Presented: View, Controller: UIHostingController<Presented> {

    @Binding private var isPresented: Bool
    @State private var presentingViewController: UIViewController?

    private let content: () -> Presented
    private let viewController: (Presented) -> Controller

    init(isPresented: Binding<Bool>,
         content: @escaping () -> Presented,
         viewController: @escaping (Presented) -> Controller) {

        _isPresented = isPresented
        self.content = content
        self.viewController = viewController
    }

    func body(content: Content) -> some View {
        content
            .background(BottomSheetBridgeView { proxy -> EmptyView in

                present(from: proxy.view, isPresented: isPresented)
                return EmptyView()
            })
    }

    private func present(from view: UIView, isPresented: Bool) {

        if isPresented == false {

            dismiss()
            return
        }

        present(from: view)
    }

    private func present(from view: UIView) {

        guard let presentingViewController = nearestViewController(view) else {
            return
        }

        guard presentingViewController.presentedViewController == nil else {
            (presentingViewController.presentedViewController as? Controller)?.rootView = content()
            return
        }

        let presentedController = viewController(content())
        presentingViewController.present(presentedController, animated: true)

        DispatchQueue.main.async {
            self.presentingViewController = presentingViewController
        }
    }

    private func dismiss() {

        presentingViewController?.presentedViewController?.dismiss(animated: true)
    }

    private func nearestViewController(_ view: UIView) -> UIViewController? {

        var responder: UIResponder? = view as UIResponder

        while responder != nil {

            if let controller = responder as? UIViewController {
                return controller
            }

            responder = responder?.next
        }

        return nil
    }
}

// MARK: - Bridge

struct BottomSheetBridgeView<Content>: View where Content: View {

    @State private var bridgeView = BridgeView()
    private let content: (Proxy) -> Content

    public init(content: @escaping (Proxy) -> Content) {
        self.content = content
    }

    public var body: some View {

        content(Proxy(view: bridgeView.view))
            .background(bridgeView)
    }
}

extension BottomSheetBridgeView {

    struct Proxy {

        let view: UIView
    }

    struct BridgeView: UIViewRepresentable {

        let view: UIView = UIView()

        func makeUIView(context: Context) -> some UIView {

            view.backgroundColor = .clear
            view.layer.opacity = 0

            return view
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {}
    }
}
