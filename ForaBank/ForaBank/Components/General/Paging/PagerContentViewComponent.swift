//
//  PagerView.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 09.06.2022.
//

import SwiftUI

// MARK: - ViewModel

class PagerContentViewModel: ObservableObject {

    @Published var pageCount: Int
    @Published var currentIndex: Int
    @Published var isUserInteractionEnabled: Bool

    init(pageCount: Int, currentIndex: Int = 0, isUserInteractionEnabled: Bool = true) {

        self.pageCount = pageCount
        self.currentIndex = currentIndex
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
}

// MARK: - View

struct PagerContentView<Content: View>: View {

    @ObservedObject var viewModel: PagerContentViewModel

    @State var contentSize: CGSize = .zero
    @GestureState private var translation: CGFloat = 0

    var paddingShowIndicator: CGFloat {

        guard isShowIndicator == true else {
            return 0
        }

        return paddingIndicator
    }

    private var pageCount: Int {
        viewModel.pageCount
    }

    private var currentIndex: Int {
        viewModel.currentIndex
    }

    private var isUserInteractionEnabled: Bool {
        viewModel.isUserInteractionEnabled
    }

    private let spacing: CGFloat
    private let padding: CGFloat
    private let paddingIndicator: CGFloat
    private let isShowIndicator: Bool
    private let content: Content

    init(viewModel: PagerContentViewModel,
         spacing: CGFloat = 10,
         padding: CGFloat = 20,
         paddingIndicator: CGFloat = 26,
         isShowIndicator: Bool = true,
         @ViewBuilder content: () -> Content) {

        self.viewModel = viewModel
        self.spacing = spacing
        self.padding = padding
        self.paddingIndicator = paddingIndicator
        self.isShowIndicator = isShowIndicator
        self.content = content()
    }

    var body: some View {

        VStack {

            GeometryReader { proxy in

                HStack(spacing: spacing) {
                    content
                        .modifier(PagerViewModifier())
                        .padding(.top, 4)
                }
                .offset(x: -CGFloat(currentIndex) * (contentSize.width + spacing))
                .offset(x: translation)
                .padding(.horizontal, padding)
                .onDisappear { viewModel.currentIndex = 0 }
                .gesture(
                    DragGesture()
                        .updating($translation, body: { value, state, _ in

                            let width = value.translation.width

                            guard 1..<pageCount - 1 ~= currentIndex else {
                                state = width / 3
                                return
                            }

                            state = width / 2
                        })
                        .onEnded { value in

                            guard isUserInteractionEnabled else {
                                return
                            }

                            let offset = value.translation.width / (proxy.size.width / 2)
                            let newIndex = currentIndex - Int(offset)

                            if offset > 0 && currentIndex == 0 { return }
                            if offset < 0 && currentIndex == newIndex { return }

                            if offset < 0 && currentIndex == pageCount - 1 { return }
                            if offset > 0 && currentIndex == newIndex { return }

                            viewModel.currentIndex = min(max(Int(newIndex), 0), pageCount - 1)
                        }
                )
            }
            .onPreferenceChange(PagerPreferenceKey.self) { self.contentSize = $0 }
            .animation(.spring())

            if isShowIndicator == true {
                PageIndicatorView(
                    pageCount: pageCount,
                    currentIndex: $viewModel.currentIndex)
            }

        }.frame(height: contentSize.height + paddingShowIndicator)
    }
}

// MARK: - PreferenceKey

private struct PagerPreferenceKey: PreferenceKey {

    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

// MARK: - ViewModifier

private struct PagerViewModifier: ViewModifier {

    func body(content: Content) -> some View {

        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: PagerPreferenceKey.self, value: proxy.size)
            }
        )
    }
}

// MARK: - Previews

struct PagerComponentPreview: View {

    @State var currentIndex: Int = 0
    @State var isUserInteractionEnabled = true

    var itemsCount: Int {
        OpenAccountViewModel.sample.items.count
    }

    var body: some View {

        PagerContentView(viewModel: .init(
            pageCount: itemsCount,
            currentIndex: currentIndex,
            isUserInteractionEnabled: isUserInteractionEnabled)) {
                ForEach(OpenAccountViewModel.sample.items) { item in
                    OpenAccountItemView(viewModel: item)
                }
            }.padding(.top, 8)
    }
}

struct PagerViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        PagerComponentPreview()
            .frame(width: UIScreen.main.bounds.width, height: 260)
            .previewLayout(.sizeThatFits)
    }
}
