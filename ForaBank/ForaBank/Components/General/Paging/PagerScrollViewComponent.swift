//
//  PagerScrollViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.07.2022.
//

import SwiftUI

// MARK: - ViewModel

class PagerScrollViewModel: ObservableObject {
    
    @Published var pagesCount: Int
    @Published var currentIndex: Int
    @Published var isUserInteractionEnabled: Bool
    
    init(pagesCount: Int, currentIndex: Int = 0, isUserInteractionEnabled: Bool = true) {
        
        self.pagesCount = pagesCount
        self.currentIndex = currentIndex
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
}

struct PagerScrollView<Content: View>: View {
    
    @ObservedObject var viewModel: PagerScrollViewModel
    
    @State var contentSize: CGSize = .zero
    @State var offset: CGFloat = 0
    
    private var currentIndex: Int { viewModel.currentIndex }
    
    private let spacing: CGFloat
    private let padding: CGFloat
    private let content: Content
    
    init(viewModel: PagerScrollViewModel,
         spacing: CGFloat = 10,
         padding: CGFloat = 20,
         @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.spacing = spacing
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        
        VStack {
            
            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        content
                            .modifier(PagerViewModifier())
                    }
                }
                .content.offset(x: offset)
                .padding(.horizontal, padding)
                .gesture(DragGesture()
                    .onChanged { value in
                        
                        let isFirsGesture = 0..<proxy.size.width / 2 ~= offset
                        let isLastGesture = offset < proxy.size.width + offset
                        let isLastIndex = currentIndex == viewModel.pagesCount - 1
                        let isInteractionDisabled = viewModel.isUserInteractionEnabled == false
                        
                        let delta: CGFloat = isFirsGesture || isLastGesture && isLastIndex || isInteractionDisabled ? 4 : 1
                        
                        offset = value.translation.width / delta - (contentSize.width + spacing) * CGFloat(currentIndex)
                    }
                    .onEnded { value in
                        
                        if viewModel.isUserInteractionEnabled {
                            
                            if abs(value.predictedEndTranslation.width) >= proxy.size.width / 2 {
                                
                                var nextIndex: Int = value.predictedEndTranslation.width < 0 ? 1 : -1
                                nextIndex += currentIndex
                                
                                withAnimation {
                                    viewModel.currentIndex = nextIndex.indexInRange(min: 0, max: viewModel.pagesCount - 1)
                                }
                            }
                        }
                        
                        withAnimation(.easeOut) {
                            offset = -CGFloat(currentIndex) * (contentSize.width + spacing)
                        }
                    }
                )
            }.onPreferenceChange(PagerPreferenceKey.self) { self.contentSize = $0 }
            
            PageIndicatorView(
                pageCount: viewModel.pagesCount,
                currentIndex: $viewModel.currentIndex)
        }
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
