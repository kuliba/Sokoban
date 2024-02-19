//
//  ActivateSliderView.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

extension ActivateSliderView {
    
    class ViewModel: ObservableObject {
        
        @Published var state: SliderState
        
        init(state: SliderState) {
            
            self.state = state
        }
    }
}

//MARK: - View

struct ActivateSliderView: View {
    
    @ObservedObject var viewModel: ActivateSliderView.ViewModel
    
    let config: SliderConfig
    
    @State private var offsetX: CGFloat = 0
    private let totalWidth: CGFloat = 167
    private let knobWidth: CGFloat = 40
    private let knobPadding: CGFloat = 4
    
    private var slideLength: CGFloat { totalWidth - knobWidth - knobPadding * 2 }
    private var progress: CGFloat { 1 - (slideLength - offsetX) / slideLength }
    private var titleOpacity: CGFloat { max(1 - (progress * 2), 0) }
    
    var body: some View {
        
        VStack {
            
            switch viewModel.state {
            case .notActivated:
                
                ZStack {
                    
                    Capsule()
                        .foregroundColor(Color.black.opacity(0.1))
                        .opacity(1 - progress)
                    
                    Capsule()
                        .foregroundColor(Color.white.opacity(0.3))
                        .opacity(progress)
                    
                    HStack{
                        
                        Spacer()
                        
                        Text(config.itemByState(viewModel.state).title)
                            .font(config.font)
                            .foregroundColor(config.foregroundColor)
                            .opacity(titleOpacity)
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
                .frame(width: totalWidth, height: 48)
            }
        }
    }
    
    func dragOnChanged(value: DragGesture.Value) {
        
        if value.translation.width > 0 && offsetX <= totalWidth - knobWidth - knobPadding * 2 {
            
            self.offsetX = value.translation.width
        }
    }
    
    func dragOnEnded(value: DragGesture.Value, completion: () -> Void) {
        
        if self.offsetX < totalWidth - knobWidth - knobPadding * 2 {
            
            withAnimation {
                
                self.offsetX = 0
            }
            
        } else {
            
            withAnimation {
                
                self.offsetX = totalWidth - (knobWidth + knobPadding * 2)
            }
            
            completion()
        }
    }
    
    func textLabelOpacity(totalWidth: CGFloat)-> CGFloat {
        
        let halfTotalWidth = totalWidth / 2
        return (halfTotalWidth - abs(self.offsetX)) / halfTotalWidth
    }
    
    func resetState() {
        viewModel.state = .notActivated
        self.offsetX = 0
    }
}

#Preview {
    ActivateSliderView(
        viewModel: .init(state: .notActivated),
        config: .default)
}
