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
        
        @Published var leftButtons: [BaseButtonViewModel]
        @Published var rightButtons: [ButtonViewModel]
        
        @Published var background: Color
        @Published var foreground: Color
        @Published var backgroundDimm: BackgroundColorDimm?
        
        internal init(title: String,
                      subtitle: String? = nil,
                      leftButtons: [BaseButtonViewModel] = [],
                      rightButtons: [ButtonViewModel] = [],
                      background: Color = Color.textWhite,
                      foreground: Color = Color.textSecondary,
                      backgroundDimm: BackgroundColorDimm? = nil) {
            
            self.title = title
            self.subtitle = subtitle
            self.leftButtons = leftButtons
            self.rightButtons = rightButtons
            self.background = background
            self.foreground = foreground
            self.backgroundDimm = backgroundDimm
        }
        
        class BaseButtonViewModel: Identifiable {
            
            let id: UUID = UUID()
        }
        
        class ButtonViewModel: BaseButtonViewModel {
            
            let icon: Image
            let action: () -> Void
            
            init(icon: Image, action: @escaping () -> Void) {
                
                self.icon = icon
                self.action = action
                super.init()
            }
        }
        
        class BackButtonViewModel: BaseButtonViewModel {
            
            let icon: Image
            let action: () -> Void
            
            init(icon: Image, action: @escaping () -> Void) {
                
                self.icon = icon
                self.action = action
                super.init()
            }
        }
        
        struct BackgroundColorDimm {
            
            let color: Color
            let opacity: Double
        }
    }
}

struct NavigationBarView: View {

    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var leftPlaceholdersCount: Int {
        
        return max(viewModel.rightButtons.count - viewModel.leftButtons.count, 0)
    }
    
    var rightPlaceholdersCount: Int {
        
        return max(viewModel.leftButtons.count - viewModel.rightButtons.count, 0)
    }
    
    var backgroundColor: some View {
        
        guard let backgroundDimm = viewModel.backgroundDimm else {
            return AnyView(viewModel.background)
        }
        
        return AnyView(viewModel.background.overlay(backgroundDimm.color.opacity(backgroundDimm.opacity)))
    }
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            HStack(alignment: .center, spacing: 18) {
                
                ForEach(viewModel.leftButtons) { button in
                    
                    switch button {
                    case let backButtonViewModel as NavigationBarView.ViewModel.BackButtonViewModel:
                        Button {
                            
                            mode.wrappedValue.dismiss()
                            backButtonViewModel.action()
                            
                        } label: {
                            
                            backButtonViewModel.icon
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.foreground)
                        }
                        
                    case let buttonViewModel as NavigationBarView.ViewModel.ButtonViewModel:
                        Button(action: buttonViewModel.action){
                            
                            buttonViewModel.icon
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.foreground)
                        }
                    default:
                        EmptyView()
                    }
                }
                
                ForEach(0..<leftPlaceholdersCount, id: \.self) { _ in
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
                
                ForEach(0..<rightPlaceholdersCount, id: \.self) { _ in
                    Spacer().frame(width: 24, height: 24)
                }
                
                ForEach(viewModel.rightButtons) { button in
                    
                    Button(action: button.action) {
                        
                        button.icon
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(viewModel.foreground)
                    }
                }
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 18)
        .background(backgroundColor.edgesIgnoringSafeArea(.top))
    }
}

struct NavigationBarViewModifier: ViewModifier {
    
    let viewModel: NavigationBarView.ViewModel
    
    func body(content: Content) -> some View {
        
        VStack(spacing: 0) {
            
            NavigationBarView(viewModel: viewModel)
            content
        }
        .navigationBarHidden(true)
    }
}

extension View {
    
    func navigationBar(with viewModel: NavigationBarView.ViewModel) -> some View {
        
        self.modifier(NavigationBarViewModifier(viewModel: viewModel))
    }
}

extension NavigationBarView.ViewModel {
    
    static let sample = NavigationBarView.ViewModel(
        title: "Заголовок экрана",
        leftButtons: [
            NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft, action: {})
        ],
        rightButtons: [
            .init(icon: .ic24Settings, action: { })
        ])
}

struct NavigationBarView_Previews: PreviewProvider {
    
    static let model = NavigationBarView.ViewModel(
        title: "Перевод по номеру телефона",
        subtitle: "* 4329",                     //Optional
        leftButtons: [
            NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft, action: {})
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
