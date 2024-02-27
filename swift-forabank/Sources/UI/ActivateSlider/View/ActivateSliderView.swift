//
//  ActivateSliderView.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

struct ActivateSliderView: View {
    
    @StateObject private var viewModel: SliderViewModel
    
    let state: CardState
    let event: (CardEvent) -> Void
    let dragOnChanged: (CGFloat) -> Void
    let dragOnEnded: () -> Void
    
    let config: SliderConfig
    
    init(
        viewModel: SliderViewModel,
        state: CardState,
        event: @escaping (CardEvent) -> Void,
        config: SliderConfig
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.state = state
        self.event = event
        self.dragOnChanged = viewModel.dragOnChanged
        self.dragOnEnded = viewModel.dragOnEnded
        self.config = config
    }
    
    var body: some View {
        
        VStack {
            
            switch state {
            case .active:
                EmptyView()
            case let .status(status):
                switch status {
                    
                case nil:
                    leftSwitchView(nil)
                case .some:
                    rightSwipeView(status)
                }
            }
        }
    }
    
    private func leftSwitchView(_ state: CardState.Status?) -> some View {
        
        ZStack {
            
            Capsule()
                .foregroundColor(config.colors.backgroundColor)
                .opacity(config.backgroundOpacityBy(offsetX: viewModel.offsetX))
            
            Text(config.itemForState(state).title)
                .font(config.font)
                .foregroundColor(config.colors.foregroundColor)
                .opacity(config.titleOpacityBy(offsetX: viewModel.offsetX))
                .padding(.trailing, 14)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            ThumbView(config: config.thumbConfig(state))
                .padding(.all, 4)
                .offset(x: viewModel.offsetX, y: 0)
                .gesture(
                    DragGesture(coordinateSpace: .local)
                        .onChanged { dragOnChanged($0.translation.width)
                        }
                        .onEnded {_ in
                            dragOnEnded()
                        }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: config.sizes.totalWidth, height: 48)
        .animation(.default, value: viewModel.offsetX)
    }
    
    private func rightSwipeView(_ state: CardState.Status?) -> some View {
        
        ZStack {
            
            Capsule()
                .foregroundColor(Color.white.opacity(0.3))
            
            Text(config.itemForState(state).title)
                .font(config.font)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(config.colors.foregroundColor)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ThumbView(config: config.thumbConfig(state))
                .padding(.all, 4)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: config.sizes.totalWidth, height: 48)
    }
}

struct ActivateSliderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    viewModel: .init(
                        maxOffsetX: SliderConfig.default.maxOffsetX,
                        didSwitchOn: {}
                    ),
                    state: .status(nil),
                    event: {_ in },
                    config: .default
                )
            }
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    viewModel: .init(
                        maxOffsetX: SliderConfig.default.maxOffsetX,
                        didSwitchOn: {}
                    ),
                    state: .status(.confirmActivate),
                    event: {_ in },
                    config: .default
                )
            }
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    viewModel: .init(
                        maxOffsetX: SliderConfig.default.maxOffsetX,
                        didSwitchOn: {}
                    ),
                    state: .status(.inflight),
                    event: {_ in },
                    config: .default
                )
            }
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    viewModel: .init(
                        maxOffsetX: SliderConfig.default.maxOffsetX,
                        didSwitchOn: {}
                    ),
                    state: .status(.activated),
                    event: {_ in },
                    config: .default
                )
            }
        }
    }
}

extension SliderConfig {
    
    private var slideLength: CGFloat { sizes.totalWidth - sizes.thumbWidth - sizes.thumbPadding * 2 }
    
    var maxOffsetX: CGFloat { sizes.totalWidth - (sizes.thumbWidth + sizes.thumbPadding * 2) }
    
    func thumbConfig(_ state: CardState.Status?) -> ThumbConfig {
        
        let itemConfig = itemForState(state)
        let isAnimated: Bool = {
            
            if case .inflight = state { return true }
            return false
        }()
        
        return .init(
            icon: itemConfig.icon,
            color: colors.thumbIconColor,
            backgroundColor: colors.backgroundColor,
            foregroundColor: colors.foregroundColor,
            isAnimated: isAnimated
        )
    }
    
    func progressBy(
        offsetX: CGFloat
    ) -> CGFloat {
        
        1 - (slideLength - offsetX) / slideLength
    }
    
    func titleOpacityBy(
        offsetX: CGFloat
    ) -> CGFloat {
        
        max(1 - (progressBy(offsetX: offsetX) * 2), 0)
    }
    
    func backgroundOpacityBy(
        offsetX: CGFloat
    ) -> CGFloat {
        
        max(1 - (progressBy(offsetX: offsetX) * 2), 0.7)
    }
    
    func itemForState(_ state: CardState.Status?) -> Item {
        
        switch state {
        case .activated:
            return items.activated
            
        case .confirmActivate:
            return items.confirmingActivation
            
        case .inflight:
            return items.activating
            
        case .none:
            return items.notActivated
        }
    }
}
