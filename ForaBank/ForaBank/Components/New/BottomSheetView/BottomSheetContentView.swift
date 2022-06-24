//
//  BottomSheetContentView.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 30.05.2022.
//

import SwiftUI

// MARK: - View

struct BottomSheetContentView<Content: View>: View {

    @Binding var isShowBottomSheet: Bool

    var onDismiss: (() -> Void)?
    var content: () -> Content

    init(_ isShowBottomSheet: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {

        _isShowBottomSheet = isShowBottomSheet
        self.onDismiss = onDismiss
        self.content = content
    }

    var body: some View {

        ZStack(alignment: .bottom) {

            if isShowBottomSheet {

                DimmingView($isShowBottomSheet)

                ContentView(
                    $isShowBottomSheet,
                    onDismiss: onDismiss,
                    content: content)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
}

extension BottomSheetContentView {

    struct DimmingView: View {

        @ObservedObject var keyboardPublisher = KeyboardPublisher()

        @Binding var isShowBottomSheet: Bool

        init(_ isShowBottomSheet: Binding<Bool>) {
            _isShowBottomSheet = isShowBottomSheet
        }

        var body: some View {

            Color.mainColorsBlack
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onTapGesture()
                }
        }

        private func onTapGesture() {

            guard keyboardPublisher.isKeyboardPresented == false else {
                UIApplication.shared.endEditing()
                return
            }

            isShowBottomSheet.toggle()
        }
    }

    struct ContentView: View {

        @Binding var isShowBottomSheet: Bool

        var onDismiss: (() -> Void)?
        var content: () -> Content

        var topDragView: some View {

            ZStack {

                Color.mainColorsWhite

                Capsule()
                    .fill(Color.mainColorsGrayMedium)
                    .frame(width: 48, height: 5)
            }
            .frame(width: UIScreen.main.bounds.width, height: 21)
            .onTapGesture {
                isShowBottomSheet.toggle()
            }
        }

        init(_ isShowBottomSheet: Binding<Bool>, onDismiss: (() -> Void)? = nil, content: @escaping () -> Content) {

            _isShowBottomSheet = isShowBottomSheet
            self.onDismiss = onDismiss
            self.content = content
        }

        var body: some View {

            VStack(spacing: 0) {

                topDragView
                content()

            }.modifier(BottomSheetContentViewModifier($isShowBottomSheet, onDismiss: onDismiss))
        }
    }
}

//MARK: - PreferenceKey

struct BottomSheetPreferenceKey: PreferenceKey {

    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        _ = nextValue()
    }
}

//MARK: - ViewModifiers

private struct BottomSheetViewModifier: ViewModifier {

    func body(content: Content) -> some View {

        content.background(
            GeometryReader { proxy in
                Color.mainColorsWhite.preference(key: BottomSheetPreferenceKey.self, value: proxy.size)
            }
        )
    }
}

private struct BottomSheetContentViewModifier: ViewModifier {

    @ObservedObject var keyboardPublisher = KeyboardPublisher()

    @Binding var isShowBottomSheet: Bool

    @State private var offset: CGSize = .zero
    @State private var contentSize: CGSize = .zero

    private var keyboardHeight: CGFloat {

        if keyboardPublisher.isKeyboardPresented == true {
            return keyboardPublisher.keyboardHeight * 0.71
        }

        return 0
    }

    var onDismiss: (() -> Void)?

    init(_ isShowBottomSheet: Binding<Bool>, onDismiss: (() -> Void)? = nil) {

        _isShowBottomSheet = isShowBottomSheet
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {

        content
            .frame(width: UIScreen.main.bounds.width)
            .modifier(BottomSheetViewModifier())
            .onPreferenceChange(BottomSheetPreferenceKey.self, perform: { self.contentSize = $0 })
            .cornerRadius(12)
            .offset(y: offset.height + keyboardHeight)
            .shadow(color: .mainColorsGray, radius: 4)
            .animation(.spring())
            .transition(.move(edge: .bottom))
            .onDisappear(perform: {
                if let onDismiss = onDismiss { onDismiss() }
            })
            .gesture(
                DragGesture()
                    .onChanged { value in

                        guard value.translation.height > 0 else { return }
                        offset = value.translation
                    }
                    .onEnded { value in

                        guard isShowBottomSheet == true else { return }
                        hideBottomSheetIfNeeds(value.translation.height)
                    })
    }

    private func hideBottomSheetIfNeeds(_ dragGestureOffset: CGFloat) {

        if dragGestureOffset > contentSize.height / 3 {
            isShowBottomSheet.toggle()
        }

        offset = .zero
    }
}

//MARK: - Preview

struct PreviewBottomContentSheetView: View {

    @State var showBottomSheet: Bool = false

    var body: some View {

        ZStack {

            Button {

                withAnimation {
                    showBottomSheet.toggle()
                }
            } label: {

                Text("Show bottom sheet")
                    .foregroundColor(.mainColorsGray)
                    .font(.textH4R16240())
            }

            BottomSheetContentView($showBottomSheet) {
                Color.mainColorsGrayLightest
                    .frame(height: 250)
            }
        }
    }
}

struct BottomSheetContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewBottomContentSheetView()
    }
}

//MARK: - View

extension View {

    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {

        ZStack {
            self
            BottomSheetContentView(isPresented, onDismiss: onDismiss, content: content)
        }
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
            }
        }
    }
}
