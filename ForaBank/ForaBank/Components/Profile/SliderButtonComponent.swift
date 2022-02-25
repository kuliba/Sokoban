//
//  SliderButton.swift
//  ForaBank
//
//  Created by Дмитрий on 25.02.2022.
//

import SwiftUI


extension SliderButtonComponent {
    
    class ViewModel: ObservableObject {
        
        @Published var position: CGFloat
        @State var alertPresented: Bool
        @State var sliderState: SliderState
        let foregroundColor: Color
        
        init(position: CGFloat = 0.0, alertPresented: Bool, sliderState: SliderState, foregraundColor: Color) {
            
            self.position = position
            self.alertPresented = alertPresented
            self.sliderState = sliderState
            self.foregroundColor = foregraundColor
        }

        enum SliderState {

            case normal
            case update
        }
    }
}

struct SliderButtonComponent: View {
    
    @ObservedObject var viewModel: SliderButtonComponent.ViewModel
    
    
    var body: some View {
            
            TriggerSlider(sliderView: {
                
                RoundedRectangle(cornerRadius: 30, style: .continuous).fill(Color.white)
                    .overlay(Image.ic24ArrowRight.font(.system(size: 14)).foregroundColor(viewModel.foregroundColor))
                
            }, textView: {
                
            
                Text("Активировать").foregroundColor(Color.white)
                        .font(.system(size: 14))
    
                
            }, backgroundView: {
                
                RoundedRectangle(cornerRadius: 90, style: .circular)
                    .fill(Color.black.opacity(0.1))
                
            }, offsetX: $viewModel.position,
                didSlideToEnd: {
                
                viewModel.alertPresented = true
                
            }, settings: TriggerSliderSettings(sliderViewHeight: 167, sliderViewWidth: 48, sliderViewHPadding: 4, sliderViewVPadding: 4, slideDirection: .right))
                .frame(width: 167, height: 48)
    }
}

struct SliderButton_Previews: PreviewProvider {
    static var previews: some View {
        SliderButtonComponent(viewModel: SliderButtonComponent.ViewModel(alertPresented: false, sliderState: .normal, foregraundColor: Color.black))
    }
}

public struct TriggerSlider<SliderView: View, BackgroundView: View, TextView: View>: View {
    
    var sliderView: SliderView
    var textView: TextView
    var backgroundView: BackgroundView
    
    public var didSlideToEnd: ()->Void
    
    var settings: TriggerSliderSettings
    
    @Binding var offsetX: CGFloat
    
    public init(@ViewBuilder sliderView: ()->SliderView, textView: ()->TextView, backgroundView: ()->BackgroundView, offsetX: Binding<CGFloat>, didSlideToEnd: @escaping ()->Void, settings: TriggerSliderSettings = TriggerSliderSettings()) {
        
        self.sliderView = sliderView()
        self.backgroundView = backgroundView()
        self.textView = textView()
        self._offsetX = offsetX
        self.didSlideToEnd = didSlideToEnd
        self.settings = settings
    }
    
    public var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                backgroundView
                    .frame(width: 167, height: 48)
                
                HStack{

                    Spacer()

                    textView
                        .opacity(self.textLabelOpacity(totalWidth: proxy.size.width))
                        .padding(.trailing, 11)
                }
                
                HStack {
                    
                    self.sliderView
                        .frame(width: 40, height: 40)
                        .padding(.all, 4)
                        .offset(x: self.offsetX, y: 0)
                        .gesture(DragGesture(coordinateSpace: .local).onChanged({ value in
                            
                            self.dragOnChanged(value: value, totalWidth: proxy.size.width)
                            
                        }).onEnded({ value in
                            self.dragOnEnded(value: value, totalWidth: proxy.size.width)
                            
                        }))
                    
                    if settings.slideDirection == .right {
                        Spacer()
                    }
                }
                
            }
        }
    }
    
    func dragOnChanged(value: DragGesture.Value, totalWidth: CGFloat) {
        
        let rightSlidingChangeCondition = settings.slideDirection == .right && value.translation.width > 0 && offsetX <= totalWidth  - settings.sliderViewWidth - settings.sliderViewHPadding * 2
        let leftSlidingChangeCondition = settings.slideDirection == .left && value.translation.width < 0 && offsetX >= -totalWidth  + settings.sliderViewWidth + settings.sliderViewHPadding * 2
        
        if rightSlidingChangeCondition || leftSlidingChangeCondition  {
            self.offsetX = value.translation.width
        }
    }
    
    func dragOnEnded(value: DragGesture.Value, totalWidth: CGFloat) {
        
        let resetConditionSlideRight = self.settings.slideDirection == .right && self.offsetX < totalWidth - settings.sliderViewWidth - settings.sliderViewHPadding * 2
        
        let resetConditionSlideLeft = self.settings.slideDirection == .left && self.offsetX > -(totalWidth - settings.sliderViewWidth - settings.sliderViewHPadding * 2)
        
        if resetConditionSlideRight || resetConditionSlideLeft {
            withAnimation {
                self.offsetX = 0
            }
        } else {
            self.didSlideToEnd()
        }
    }
    
    func textLabelOpacity(totalWidth: CGFloat)->CGFloat {
        let halfTotalWidth =  totalWidth / 2
        return (halfTotalWidth - abs(self.offsetX)) / halfTotalWidth
    }
}

public struct TriggerSliderSettings {
    
    public init(sliderViewHeight: CGFloat = 40, sliderViewWidth: CGFloat = 40, sliderViewHPadding: CGFloat = 0, sliderViewVPadding:CGFloat = 0, slideDirection: SlideDirection = .right) {
        self.sliderViewWidth = sliderViewWidth
        self.sliderViewHeight = sliderViewHeight
        self.sliderViewHPadding = sliderViewHPadding
        self.sliderViewVPadding = sliderViewVPadding
        self.slideDirection = slideDirection
    }
    
    var sliderViewHeight: CGFloat
    var sliderViewWidth: CGFloat
    var sliderViewHPadding: CGFloat
    var sliderViewVPadding: CGFloat
    var slideDirection: SlideDirection
    
}

public enum SlideDirection {
    case left, right
}
