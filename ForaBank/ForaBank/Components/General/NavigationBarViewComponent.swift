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
        @Published var titleButton: TitleButtonViewModel?
        @Published var subtitle: String?
        
        @Published var leftItems: [ItemViewModel]
        @Published var rightItems: [ItemViewModel]
        
        @Published var background: Color
        @Published var foreground: Color
        @Published var backgroundDimm: BackgroundColorDimm?
        
        init(title: String = "",
             titleButton: TitleButtonViewModel? = nil,
             subtitle: String? = nil,
             leftItems: [ItemViewModel] = [],
             rightItems: [ItemViewModel] = [],
             background: Color = Color.textWhite,
             foreground: Color = Color.textSecondary,
             backgroundDimm: BackgroundColorDimm? = nil) {
            
            self.title = title
            self.titleButton = titleButton
            self.subtitle = subtitle
            self.leftItems = leftItems
            self.rightItems = rightItems
            self.background = background
            self.foreground = foreground
            self.backgroundDimm = backgroundDimm
        }
        
        convenience init(with parameters: [PaymentsParameterRepresentable], closeAction: @escaping () -> Void) {
            
            let headerParameterId = Payments.Parameter.Identifier.header.rawValue
            if let headerParameter = parameters.first(where: { $0.id == headerParameterId }) as? Payments.ParameterHeader {
                
                let backButton = BackButtonItemViewModel(action: closeAction)
                
                var rightButton = [ItemViewModel]()
                
                if let icon = headerParameter.icon {
                    
                    switch icon {
                    case let .image(imageData):
                        if let iconImage = imageData.image {
                            
                            let imageItem = IconItemViewModel(icon: iconImage)
                            rightButton.append(imageItem)
                        }
                        
                    case let .name(imageName):
                        let imageItem = IconItemViewModel(icon: Image(imageName))
                        rightButton.append(imageItem)
                    }
                }
                
                for button in headerParameter.rightButton {
                    
                    guard let icon = button.icon.image else {
                        break
                    }
                    
                    switch button.action {
                    case .scanQrCode:
                        rightButton.append(ButtonItemViewModel.init(icon: icon, action: {
                             //setup qr code view action
                        }))
                    }
                }
                
                if let subtitle = headerParameter.subtitle {
                    
                    self.init(title: headerParameter.title, subtitle: subtitle, leftItems: [backButton], rightItems: rightButton)
                    
                } else {
                    
                    self.init(title: headerParameter.title, subtitle: nil, leftItems: [backButton], rightItems: rightButton)
                }
                 
            } else {
                
                self.init()
            }
        }
    }
}

//MARK: - Types

extension NavigationBarView.ViewModel {
    
    class ItemViewModel: Identifiable {
        
        let id: UUID = UUID()
    }
    
    struct TitleButtonViewModel {
        
        let icon: Image
        let action: () -> Void
        
        init(icon: Image, action: @escaping () -> Void) {
            
            self.icon = icon
            self.action = action
        }
    }
    
    class ButtonItemViewModel: ItemViewModel {
                
        @Published var isDisabled: Bool
        let icon: Image
        let action: () -> Void

        init(icon: Image, isDisabled: Bool = false, action: @escaping () -> Void) {
                    
            self.icon = icon
            self.isDisabled = isDisabled
            self.action = action
            super.init()
        }
    }
    
    class ButtonMarkedItemViewModel: ItemViewModel {
                
        @Published var isDisabled: Bool
        @Published var markedDot: MarkedDotViewModel?
                
        var icon: Image
        let action: () -> Void

        init(icon: Image, isDisabled: Bool = false, markedDot: MarkedDotViewModel? = nil, action: @escaping () -> Void) {
                    
            self.icon = icon
            self.isDisabled = isDisabled
            self.markedDot = markedDot
            self.action = action
            super.init()
        }

        struct MarkedDotViewModel {

            var color: Color = .red
            let isBlinking: Bool
        }
    }
    
    class BackButtonItemViewModel: ItemViewModel {
        
        let icon: Image
        let action: () -> Void
        
        init(icon: Image = .ic24ChevronLeft, action: @escaping () -> Void) {
            
            self.icon = icon
            self.action = action
            super.init()
        }
    }
    
    class IconItemViewModel: ItemViewModel {
        
        let icon: Image
        
        init(icon: Image) {
            
            self.icon = icon
            super.init()
        }
    }
    
    struct BackgroundColorDimm {
        
        let color: Color
        let opacity: Double
    }
}

//MARK: - View

struct NavigationBarView: View {

    @ObservedObject var viewModel: ViewModel

    var leftPlaceholdersCount: Int {
        
        return max(viewModel.rightItems.count - viewModel.leftItems.count, 0)
    }
    
    var rightPlaceholdersCount: Int {
        
        return max(viewModel.leftItems.count - viewModel.rightItems.count, 0)
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
                
                ForEach(viewModel.leftItems) { item in
                    
                    view(for: item, foregroundColor: viewModel.foreground, backgroundColor: viewModel.background)
                }
                
                ForEach(0..<leftPlaceholdersCount, id: \.self) { _ in
                    Spacer().frame(width: 24, height: 24)
                }
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                
                VStack(alignment: .center, spacing: 0) {
                    
                    Text(viewModel.title)
                        .font(.textH3M18240())
                        .foregroundColor(viewModel.foreground)
                        .lineLimit(1)
                        .accessibilityIdentifier("navigationTitle")
  
                    if let subtitle = viewModel.subtitle {
                        
                        Text(subtitle)
                            .font(.textBodySR12160())
                            .foregroundColor(viewModel.foreground)
                            .lineLimit(1)
                    }
                }
                
                Button {
                    
                    viewModel.titleButton?.action()
                    
                } label: {
                    
                    viewModel.titleButton?.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(viewModel.foreground)
                        .accessibilityIdentifier("navigationSubTitle")
                }
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 18) {
                
                ForEach(0..<rightPlaceholdersCount, id: \.self) { _ in
                    Spacer().frame(width: 24, height: 24)
                }
                
                ForEach(viewModel.rightItems) { item in
                    
                    view(for: item, foregroundColor: viewModel.foreground, backgroundColor: viewModel.background)
                }
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 15)
        .background(backgroundColor.edgesIgnoringSafeArea(.top))
    }
}

//MARK: - Helpers

extension NavigationBarView {
    
    func view(for item: ViewModel.ItemViewModel, foregroundColor: Color, backgroundColor: Color) -> AnyView {
        
        switch item {
        case let backButtonItem as NavigationBarView.ViewModel.BackButtonItemViewModel:
            return AnyView(BackButtonItemView(viewModel: backButtonItem, foregroundColor: foregroundColor))
        
        case let buttonItem as NavigationBarView.ViewModel.ButtonItemViewModel:
            return AnyView(ButtonItemView(viewModel: buttonItem, foregroundColor: foregroundColor))
            
        case let buttonMarkedItem as NavigationBarView.ViewModel.ButtonMarkedItemViewModel:
            return AnyView(ButtonMarkedItemView(viewModel: buttonMarkedItem, foreground: foregroundColor, background: backgroundColor))
            
        case let iconItem as NavigationBarView.ViewModel.IconItemViewModel:
            return AnyView(IconItemView(viewModel: iconItem))
            
        default:
            return AnyView(EmptyView())
        }
    }
}

//MARK: - Subviews

extension NavigationBarView {
    
    struct BackButtonItemView: View {
        
        let viewModel: ViewModel.BackButtonItemViewModel
        let foregroundColor: Color
        @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
        
        var body: some View {
            
            Button {
                
                mode.wrappedValue.dismiss()
                viewModel.action()
                
            } label: {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(foregroundColor)
            }
        }
    }
    
    struct ButtonItemView: View {
        
        let viewModel: ViewModel.ButtonItemViewModel
        let foregroundColor: Color
 
        var body: some View {
            
            Button(action: viewModel.action) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(foregroundColor)
            }
        }
    }
    
    struct ButtonMarkedItemView: View {
        
        @State var blinking: Bool = false
        var viewModel: ViewModel.ButtonMarkedItemViewModel
        let foreground: Color
        let background: Color
        
        var body: some View {
            
            Button(action: viewModel.action) {
            
                ZStack(alignment: .leading) {
                
                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(viewModel.isDisabled ? .mainColorsGrayMedium
                                                              : foreground)
                
                    if let markedDot = viewModel.markedDot {
                    
                        if markedDot.isBlinking {
                        
                            Circle()
                                .fill(blinking ? background : Color.red)
                                .background(Circle().stroke(background, lineWidth: 3))
                                .frame(width: 7)
                                .offset(x: 0, y: -6)
                                .animation(Animation.easeInOut(duration: 1.2)
                                    .repeatForever(autoreverses: true), value: blinking)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(
                                        deadline: .now() + .milliseconds(50)) {
                                            blinking = true
                                    }
                                }
                        } else {
                        
                            Circle()
                                .fill(Color.red)
                                .background(Circle().stroke(background, lineWidth: 3))
                                .frame(width: 7)
                                .offset(x: 0, y: -6)
                                .animation(nil)
                        }
                    }
                } //zstack
            } //button
            .disabled(viewModel.isDisabled)
        }
    }
    
    struct IconItemView: View {
        
        let viewModel: ViewModel.IconItemViewModel
 
        var body: some View {
            
            viewModel.icon
                .resizable()
                .renderingMode(.original)
                .frame(width: 24, height: 24)
        }
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
        leftItems: [
            NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})
        ],
        rightItems: [
            NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic24Settings, action: { })
        ])
}

struct NavigationBarView_Previews: PreviewProvider {
    
    static let model = NavigationBarView.ViewModel(
        title: "Перевод по номеру телефона",
        subtitle: "* 4329",                     //Optional
        leftItems: [
            NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})
        ],
        rightItems: [
            NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic24Share, action: { }),
            NavigationBarView.ViewModel.ButtonMarkedItemViewModel(icon: .ic24BarInOrder, markedDot: .init(isBlinking: true), action: { })
        ],
        background:  .barsTabbar                  //Optional
        //foreground: .textWhite                  //Optional
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
