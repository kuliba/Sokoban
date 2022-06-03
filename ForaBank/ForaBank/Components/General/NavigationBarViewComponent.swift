//
//  NavigationBarViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2022.
//

import SwiftUI

extension NavigationBarView {
    
    class ViewModel: ObservableObject {
        
        @Published var title: String
        @Published var subtitle: String?
        
        @Published var leftButtons: [ButtonViewModel]
        @Published var rightButtons: [ButtonViewModel]
        
        let background: Color
        let foreground: Color
        
        internal init(title: String,
                      subtitle: String? = nil,
                      leftButtons: [ButtonViewModel] = [],
                      rightButtons: [ButtonViewModel] = [],
                      background: Color = Color.textWhite,
                      foreground: Color = Color.textSecondary) {
            
            self.title = title
            self.subtitle = subtitle
            self.leftButtons = leftButtons
            self.rightButtons = rightButtons
            self.background = background
            self.foreground = foreground
        }
        
        struct ButtonViewModel: Identifiable {
            
            let id: UUID = UUID()
            let icon: Image
            let action: () -> Void
            
            init(icon: Image, action: @escaping () -> Void) {
                
                self.icon = icon
                self.action = action
            }
        }
    }
}

struct NavigationBarView: View {

    @ObservedObject var viewModel: ViewModel
    
    var leftPlaceholders: Int {
        
        let left = viewModel.leftButtons.count
        let right = viewModel.rightButtons.count
        
        if left < right {
            return right - left
        } else {
            return 0
        }
    }
    
    var rightPlaceholders: Int {
        
        let left = viewModel.leftButtons.count
        let right = viewModel.rightButtons.count
        
        if left > right {
            return left - right
        } else {
            return 0
        }
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            ZStack {
                
                viewModel.background
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 48)
                
                HStack {
                    
                    HStack(alignment: .center, spacing: 18) {
                        
                        ForEach(viewModel.leftButtons) { button in
                            
                            Button {
                                
                                button.action()
                                
                            } label: {
                                
                                button.icon
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(viewModel.foreground)
                            }
                        }
                        
                        ForEach(0..<leftPlaceholders, id: \.self) { _ in
                            Spacer().frame(width: 24, height: 24)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 0) {
                        
                        Text(viewModel.title)
                            .font(.textH3M18240())
                            .foregroundColor(viewModel.foreground)
                            .lineLimit(1)
                           
                        if let subtitle = viewModel.subtitle {
                            
                            Text(subtitle)
                                .font(.textBodySR12160())
                                .foregroundColor(viewModel.foreground)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 18) {
                        
                        ForEach(0..<rightPlaceholders, id: \.self) { _ in
                            Spacer().frame(width: 24, height: 24)
                        }
                        
                        ForEach(viewModel.rightButtons) { button in
                            
                            Button {
                                
                                button.action()
                                
                            } label: {
                                
                                button.icon
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(viewModel.foreground)
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .background(viewModel.background)
            }
            
            Spacer()
        }
    }
}

struct NavigationBarViewModifier: ViewModifier {
    
    @ObservedObject var viewModel: NavigationBarView.ViewModel
    
    func body(content: Content) -> some View {
        
        ZStack {
            
            VStack {
                
                Spacer().frame(height: 48)
                
                content
            }
            
            NavigationBarView(viewModel: viewModel)
        }
        .navigationBarHidden(true)
    }
}

extension View {
    
    func navigationBar(with viewModel: NavigationBarView.ViewModel) -> some View {
        
        self.modifier(NavigationBarViewModifier(viewModel: viewModel))
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    
    static let model = NavigationBarView.ViewModel(
        title: "Перевод по номеру телефона",
        subtitle: "* 4329",                     //Optional
        leftButtons: [
            .init(icon: .ic24ChevronLeft, action: { })
        ],
        rightButtons: [
            .init(icon: .ic24Share, action: { }),
            .init(icon: .ic24Settings, action: { })
        ],
        background: .bGIconDeepPurpleMedium,    //Optional
        foreground: .textWhite                  //Optional
    )
    
    static var previews: some View {
        
        Group {
            
            ScrollView {
                
                ZStack {
                    
                    Color.bGIconGrayLightest
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Color.bGIconDeepBlueLight
                            .frame(height: 50)
                        Color.bGIconDeepLimeLight
                            .frame(height: 50)
                        Color.bGIconDeepIndigoLight
                            .frame(height: 50)
                        Color.bGIconDeepOrangeLight
                            .frame(height: 50)
                    }
                }
            }
            .navigationBar(with: self.model)
            
        }
    }
}
