//
//  CardActivateSliderViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 25.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension CardActivateSliderView {
    
    class ViewModel: ObservableObject {
        
        @Published var state: State
        let knobIconColor: Color
        let foregroundColor: Color

        init(state: State, knobIconColor: Color = .black, foregroundColor: Color = .white) {
            
            self.state = state
            self.knobIconColor = knobIconColor
            self.foregroundColor = foregroundColor
        }
        
        enum State {
            
            case notActivated
            case activating
            case activated
            
            var knobIcon: Image {
                
                switch self {
                case .notActivated: return .ic24ArrowRight
                case .activating: return .ic24RefreshCw
                case .activated: return .ic24Check
                }
            }
            
            var title: String {
                
                switch self {
                case .notActivated: return "Активировать"
                case .activating: return "Данные обновляются"
                case .activated: return "Карта активирована"
                }
            }
        }
    }
}

//MARK: - View

struct CardActivateSliderView: View {
    
    @ObservedObject var viewModel: CardActivateSliderView.ViewModel
    
    @State private var offsetX: CGFloat = 0
    private let totalWidth: CGFloat = 167
    private let knobWidth: CGFloat = 40
    private let knobPadding: CGFloat = 4
    
    private var slideLength: CGFloat { totalWidth - knobWidth - knobPadding * 2 }
    private var progress: CGFloat { 1 - (slideLength - offsetX) / slideLength }
    private var titleOpacity: CGFloat { max(1 - (progress * 2), 0) }
    
    var body: some View {
        
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

                    Text(viewModel.state.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(viewModel.foregroundColor)
                        .opacity(titleOpacity)
                        .padding(.trailing, 14)
                        .frame(width: 120)
                }
                
                HStack {
                    
                    KnobView(icon: viewModel.state.knobIcon, color: viewModel.knobIconColor, backgroundColor: viewModel.foregroundColor, isAnimated: false)
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
            
        case .activating, .activated:
            ZStack {
                
                Capsule()
                    .foregroundColor(Color.white.opacity(0.3))

                HStack{

                    Text(viewModel.state.title)
                        .font(.textBodyMR14200())
                        .multilineTextAlignment(.center)
                        .foregroundColor(viewModel.foregroundColor)
                        .padding(.leading, 11)
                        .frame(width: 120)
                    
                    Spacer()
                }
                
                HStack {
                    
                    Spacer()
                    
                    KnobView(icon: viewModel.state.knobIcon, color: viewModel.knobIconColor, backgroundColor: viewModel.foregroundColor, isAnimated: viewModel.state == .activating ? true : false)
                        .padding(.all, 4)
                }
            }
            .frame(width: totalWidth, height: 48)
            
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
}

extension CardActivateSliderView {
    
    struct KnobView: View {
        
        let icon: Image
        let color: Color
        let backgroundColor: Color
        let isAnimated: Bool
        @State var isAnimationStarted: Bool = false
        
        var animation: Animation { Animation.linear(duration: 1.0).repeatForever(autoreverses: false) }

        var body: some View {
            
            if isAnimated {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(backgroundColor)
                        .frame(width: 40, height: 40)
                    
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(color)
                        .frame(width: 24, height: 24)
                        .rotationEffect(Angle.degrees(isAnimationStarted ? 360 : 0))
                        .animation(animation)
                        .onAppear{ isAnimationStarted = true }
                }
                
            } else {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(backgroundColor)
                        .frame(width: 40, height: 40)
                    
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(color)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

//MARK: - Preview

struct SliderButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CardActivateSliderView(viewModel: .init(state: .notActivated))
                .previewLayout(.fixed(width: 375, height: 100))
                .background(Color.pink)
            
            CardActivateSliderView(viewModel: .init(state: .activating))
                .previewLayout(.fixed(width: 375, height: 100))
                .background(Color.pink)
            
            CardActivateSliderView(viewModel: .init(state: .activated))
                .previewLayout(.fixed(width: 375, height: 100))
                .background(Color.pink)
        }
    }
}
