//
//  PagerView.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 09.06.2022.
//

import SwiftUI

// MARK: - View

struct PagerContentView<Content: View>: View {

    @Binding var currentIndex: Int

    @State var contentSize: CGSize = .zero
    @GestureState private var translation: CGFloat = 0

    var paddingShowIndicator: CGFloat {

        guard isShowIndicator == true else {
            return 0
        }

        return paddingIndicator
    }

    private let pageCount: Int
    private let spacing: CGFloat
    private let padding: CGFloat
    private let paddingIndicator: CGFloat
    private let isShowIndicator: Bool
    private let content: Content

    init(pageCount: Int,
         currentIndex: Binding<Int>,
         spacing: CGFloat = 10,
         padding: CGFloat = 20,
         paddingIndicator: CGFloat = 26,
         isShowIndicator: Bool = true,
         @ViewBuilder content: () -> Content) {

        self.pageCount = pageCount
        _currentIndex = currentIndex
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
                .onDisappear { currentIndex = 0 }
                .gesture(
                    DragGesture()
                        .updating($translation, body: { value, state, _ in
                            state = value.translation.width / 2
                        })
                        .onEnded { value in

                            let offset = value.translation.width / (proxy.size.width / 2)
                            let newIndex = (CGFloat(currentIndex) - offset).rounded()

                            currentIndex = min(max(Int(newIndex), 0), pageCount - 1)
                        }
                )
            }
            .onPreferenceChange(PagerPreferenceKey.self) { self.contentSize = $0 }
            .animation(.spring())

            if isShowIndicator == true {
                PageIndicatorView(pageCount: pageCount, currentIndex: $currentIndex)
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

    var itemsCount: Int {
        OpenAccountViewModel.sample.items.count
    }

    var body: some View {

        PagerContentView(pageCount: itemsCount, currentIndex: $currentIndex) {
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
