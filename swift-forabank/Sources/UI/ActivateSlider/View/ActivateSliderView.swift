//
//  ActivateSliderView.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

//MARK: - View

struct ActivateSliderView: View {
    
    let state: SliderStatus
    let event: (ActivateSlider.Event) -> Void
    let config: SliderConfig
    
    @State private var offsetX: CGFloat = 0
    
    var body: some View {
        
        VStack {
            
            switch state {
            case .notActivated:
                leftSwitchView()
                
            case .activating, .activated, .waiting:
                rightSwipeView()
            }
        }
    }
    
    private func leftSwitchView() -> some View {
        
        ZStack {
            
            Capsule()
                .foregroundColor(config.backgroundColor)
                .opacity(config.backgroundOpacityBy(offsetX: offsetX))
                
                Text(config.itemForState(state).title)
                    .font(config.font)
                    .foregroundColor(config.foregroundColor)
                    .opacity(config.titleOpacityBy(offsetX: offsetX))
                    .padding(.trailing, 14)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                ThumbView(config: config.thumbConfig(state))
                    .padding(.all, 4)
                    .offset(x: self.offsetX, y: 0)
                    .gesture(DragGesture(coordinateSpace: .local).onChanged({ value in
                        
                        dragOnChanged(value: value)
                        
                    }).onEnded({ value in
                        
                        dragOnEnded(value: value) {
                            
                            withAnimation {
                                
                                //state = .activating
                                event(.swipe)
                            }
                        }
                    }))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
        }
        .frame(width: config.totalWidth, height: 48)
    }
    
    private func rightSwipeView() -> some View {
        
        ZStack {
            
            Capsule()
                .foregroundColor(Color.white.opacity(0.3))
            
                Text(config.itemForState(state).title)
                    .font(config.font)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(config.foregroundColor)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ThumbView(config: config.thumbConfig(state))
                    .padding(.all, 4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: config.totalWidth, height: 48)
    }
    
    func dragOnChanged(value: DragGesture.Value) {
        
        if value.translation.width > 0 && offsetX <= config.maxOffsetX {
            
            self.offsetX = value.translation.width
        }
    }
    
    func dragOnEnded(value: DragGesture.Value, completion: () -> Void) {
        
        if self.offsetX < config.maxOffsetX {
            
            withAnimation {
                
                self.offsetX = 0
            }
            
        } else {
            
            withAnimation {
                
                self.offsetX = config.maxOffsetX
            }
            
            completion()
        }
    }
    
    func resetState() {
        
        //state = .notActivated
        
        withAnimation {
            
            self.offsetX = 0
        }
    }
}

struct ActivateSliderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    state: .notActivated,
                    event: {_ in },
                    config: .default
                )
            }
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    state: .waiting,
                    event: {_ in },
                    config: .default
                )            }
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    state: .activating,
                    event: {_ in },
                    config: .default
                )            }
            
            ZStack {
                Color.gray
                    .frame(width: 300, height: 100)
                ActivateSliderView(
                    state: .activated,
                    event: {_ in },
                    config: .default
                )
            }
        }
    }
}

