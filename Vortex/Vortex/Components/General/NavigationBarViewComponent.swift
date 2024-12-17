//
//  NavigationBarViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2022.
//

import Combine
import SwiftUI
import UIPrimitives

extension NavigationBarView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var title: String
        @Published var titleButton: TitleButtonViewModel?
        @Published var subtitle: String?
        @Published var opacity: Double
        
        @Published var leftItems: [ItemViewModel]
        @Published var rightItems: [ItemViewModel]
        
        @Published var background: Color
        @Published var foreground: Color
        @Published var backgroundDimm: BackgroundColorDimm?
        
        init(title: String = "",
             titleButton: TitleButtonViewModel? = nil,
             subtitle: String? = nil,
             opacity: Double = 1,
             leftItems: [ItemViewModel] = [],
             rightItems: [ItemViewModel] = [],
             background: Color = Color.textWhite,
             foreground: Color = Color.textSecondary,
             backgroundDimm: BackgroundColorDimm? = nil) {
            
            self.title = title
            self.titleButton = titleButton
            self.subtitle = subtitle
            self.opacity = opacity
            self.leftItems = leftItems
            self.rightItems = rightItems
            self.background = background
            self.foreground = foreground
            self.backgroundDimm = backgroundDimm
        }

        convenience init(opacity: Double = 1, action: @escaping () -> Void) {

            let backButton: BackButtonItemViewModel = .init(icon: .ic24ChevronLeft, action: action)
            self.init(opacity: opacity, leftItems: [backButton], background: .clear)
        }
        
        convenience init(with parameters: [PaymentsParameterRepresentable], closeAction: @escaping () -> Void) {
            
            let headerParameterId = Payments.Parameter.Identifier.header.rawValue
            if let headerParameter = parameters.first(where: { $0.id == headerParameterId }) as? Payments.ParameterHeader {
                
                let backButton = BackButtonItemViewModel(action: closeAction)
                
                var rightButton = [ItemViewModel]()

                if let subtitle = headerParameter.subtitle {
                    
                    self.init(title: headerParameter.title, subtitle: subtitle, leftItems: [backButton], rightItems: rightButton)
                    
                } else {
                    
                    self.init(title: headerParameter.title, subtitle: nil, leftItems: [backButton], rightItems: rightButton)
                }
                
                for item in headerParameter.rightButton {
                    
                    switch item.action {
                        case .scanQrCode:
                            
                            guard let icon = item.icon.image else {
                                break
                            }
                            
                            rightButton.append(ButtonItemViewModel(icon: icon, action: { [weak self] in
                                self?.action.send(NavigationBarViewModelAction.ScanQrCode())
                            }))
                        case .editName:
                            guard let icon = item.icon.image else {
                                break
                            }
                            
                            rightButton.append(ButtonItemViewModel(icon: icon, action: { [weak self] in
                                if let action = headerParameter.rightButton.first?.action {
                                    switch action {
                                    case let .editName(viewModel):
                                        self?.action.send(NavigationBarViewModelAction.EditName(viewModel: viewModel))
                                    default:
                                        break
                                    }
                                }
                            }))
                    }
                }
                
                if let icon = headerParameter.icon {
                    
                    switch icon {
                    case let .image(imageData):
                        if let iconImage = imageData.image {
                            
                            let imageItem = IconItemViewModel(icon: iconImage, style: headerParameter.style)
                            rightButton.append(imageItem)
                        }
                        
                    case let .name(imageName):
                        let imageItem = IconItemViewModel(icon: Image(imageName), style: headerParameter.style)
                        rightButton.append(imageItem)
                    }
                }
                
                self.rightItems = rightButton
                
            } else {
                
                self.init()
            }
        }
    }
}

struct NavigationBarViewModelAction {
    
    struct ScanQrCode: Action {}
    
    struct EditName: Action {
        
        let viewModel: TemplatesListViewModel.RenameTemplateItemViewModel
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
        let style: Style
        
        init(icon: Image, style: Payments.ParameterHeader.Style) {
            
            self.icon = icon
            
            switch style {
            case .normal:
                self.style = .normal
                
            case .large:
                self.style = .large
            }
            
            super.init()
        }
        
        enum Style {
            
            case normal //24pt
            case large //32pt
        }
    }
    
    class AsyncImageItemViewModel: ItemViewModel {
        
        let icon: UIPrimitives.AsyncImage
        let style: Style
        
        init(
            icon: UIPrimitives.AsyncImage,
            style: Style
        ) {
            self.icon = icon
            self.style = style
            
            super.init()
        }
        
        enum Style {
            
            case normal //24pt
            case large //32pt
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
                        .opacity(viewModel.opacity)
                        .accessibilityIdentifier("navigationTitle")
  
                    if let subtitle = viewModel.subtitle {
                        
                        Text(subtitle)
                            .font(.textBodySR12160())
                            .foregroundColor(viewModel.foreground)
                            .lineLimit(1)
                            .opacity(viewModel.opacity)
                            .accessibilityIdentifier("NavigationBarSubTitle")
                    }
                }
                
                Button {
                    
                    viewModel.titleButton?.action()
                    
                } label: {
                    
                    viewModel.titleButton?.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
    
    @ViewBuilder
    func view(
        for item: ViewModel.ItemViewModel,
        foregroundColor: Color,
        backgroundColor: Color
    ) -> some View {
        
        switch item {
        case let backButtonItem as NavigationBarView.ViewModel.BackButtonItemViewModel:
            BackButtonItemView(viewModel: backButtonItem, foregroundColor: foregroundColor)
        
        case let buttonItem as NavigationBarView.ViewModel.ButtonItemViewModel:
            ButtonItemView(viewModel: buttonItem, foregroundColor: foregroundColor)
            
        case let buttonMarkedItem as NavigationBarView.ViewModel.ButtonMarkedItemViewModel:
            ButtonMarkedItemView(viewModel: buttonMarkedItem, foreground: foregroundColor, background: backgroundColor)
            
        case let iconItem as NavigationBarView.ViewModel.IconItemViewModel:
            IconItemView(viewModel: iconItem)
            
        case let asyncImage as NavigationBarView.ViewModel.AsyncImageItemViewModel:
            AsyncImageItemView(viewModel: asyncImage)
            
        default:
            EmptyView()
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
                
                viewModel.action()
                mode.wrappedValue.dismiss()
                
            } label: {
                
                viewModel.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(foregroundColor)
                    .accessibilityIdentifier("NavigationBarIcon1")
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
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(viewModel.isDisabled ? .mainColorsGrayMedium
                                         : foreground)
                        .accessibilityIdentifier("NavigationBarIcon2")
                    
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
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(frameSize)
                .accessibilityIdentifier("NavigationBarIconLarge")
        }
        
        private var frameSize: CGSize {
            
            switch viewModel.style {
            case .large: return .init(width: 32, height: 32)
            case .normal: return .init(width: 24, height: 24)
            }
        }
    }
    
    struct AsyncImageItemView: View {
        
        let viewModel: ViewModel.AsyncImageItemViewModel
        
        var body: some View {
            
            viewModel.icon
                .frame(frameSize)
                .accessibilityIdentifier("NavigationBarIconLarge")
        }
        
        private var frameSize: CGSize {
            
            switch viewModel.style {
            case .large: return .init(width: 32, height: 32)
            case .normal: return .init(width: 24, height: 24)
            }
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
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
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
        background:  .barsBars                  //Optional
        //foreground: .textWhite                  //Optional
    )
    
    static var previews: some View {
        
        Group {
            
            ScrollView {
                
                ZStack {
                    
                    Color.bgIconGrayLightest
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Color.bgIconDeepBlueLight
                            .frame(height: 50)
                        Color.bgIconDeepLimeLight
                            .frame(height: 50)
                        Color.bgIconDeepIndigoLight
                            .frame(height: 50)
                        Color.bgIconDeepOrangeLight
                            .frame(height: 50)
                    }
                }
            }
            .navigationBar(with: self.model)
        }
    }
}
