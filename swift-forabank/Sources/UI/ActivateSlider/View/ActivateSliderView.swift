//
//  ActivateSliderView.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

//MARK: - View

struct ActivateSliderView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let config: SliderConfig
    
    @State private var offsetX: CGFloat = 0
        
    var body: some View {
        
        VStack {
            
            switch viewModel.state {
            case .notActivated:
                
                ZStack {
                    
                    Capsule()
                        .foregroundColor(config.backgroundColor)
                        .opacity(1 - config.progressBy(offsetX: offsetX))
                                    
                    HStack{
                        
                        Spacer()
                        
                        Text(config.itemByState(viewModel.state).title)
                            .font(config.font)
                            .foregroundColor(config.foregroundColor)
                            .opacity(config.titleOpacityBy(offsetX: offsetX))
                            .padding(.trailing, 14)
                            .frame(width: 120)
                    }
                    
                    HStack {
                        
                        ThumbView(config: config.thumbConfig(viewModel.state))
                            .padding(.all, 4)
                            .offset(x: self.offsetX, y: 0)
                            .gesture(DragGesture(coordinateSpace: .local).onChanged({ value in
                                
                                dragOnChanged(value: value)
                                
                            }).onEnded({ value in
                                
                                dragOnEnded(value: value) {
                                    
                                    withAnimation {
                                        
                                        viewModel.state = .activating
                                    }
                                }
                            }))
                        
                        Spacer()
                    }
                }
                .frame(width: 167, height: 48)
                
            case .activating, .activated, .waiting:
                
                ZStack {
                    
                    Capsule()
                        .foregroundColor(Color.white.opacity(0.3))
                    
                    HStack{
                        
                        Text(config.itemByState(viewModel.state).title)
                            .font(config.font)
                            .multilineTextAlignment(.center)
                            .foregroundColor(config.foregroundColor)
                            .padding(.leading, 11)
                            .frame(width: 120)
                        
                        Spacer()
                    }
                    
                    HStack {
                        
                        Spacer()
                        
                        ThumbView(config: config.thumbConfig(viewModel.state))
                            .padding(.all, 4)
                    }
                }
                .frame(width: config.totalWidth, height: 48)
            }
        }
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
        viewModel.state = .notActivated
        
        withAnimation {
            
            self.offsetX = 0
        }
    }
}

#Preview {
    VStack {
        
        ZStack {
            Color.green
                .frame(width: 300, height: 100)
            ActivateSliderView(
                viewModel: .init(state: .notActivated),
                config: .default)
        }
        
        ZStack {
            Color.green
                .frame(width: 300, height: 100)
            ActivateSliderView(
                viewModel: .init(state: .activated),
                config: .default)
        }

        ZStack {
            Color.green
                .frame(width: 300, height: 100)
            ActivateSliderView(
                viewModel: .init(state: .activating),
                config: .default)
        }

    }
}
