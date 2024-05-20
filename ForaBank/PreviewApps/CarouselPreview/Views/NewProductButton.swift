import SwiftUI

struct NewProductButtonWrapperView: View {
    
    @ObservedObject var viewModel: NewProductButton.ViewModel
    
    private let config: NewProductButtonConfig
    private let action: () -> Void

    public init(
        viewModel: NewProductButton.ViewModel,
        config: NewProductButtonConfig,
        action: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.config = config
        self.action = action
    }
    
    public var body: some View {
                
        NewProductButton(
            config: config,
            action: action,
            icon: viewModel.icon,
            title: viewModel.title,
            subTitle: viewModel.subTitle,
            tapAction: viewModel.tapAction
        )
    }
}

struct NewProductButton: View {
        
    private let config: NewProductButtonConfig
    private let action: () -> Void
    
    private let icon: Image
    private let title: String
    private let subTitle: String
    private let tapAction: TapAction
    
    public init(
        config: NewProductButtonConfig,
        action: @escaping () -> Void,
        icon: Image,
        title: String,
        subTitle: String,
        tapAction: TapAction
    ) {
        self.config = config
        self.action = action
        self.icon = icon
        self.title = title
        self.subTitle = subTitle
        self.tapAction = tapAction
    }
    
    var body: some View {
        
        switch tapAction {
        case let .action(action):
            button(action)
            
        case let .url(url):
            link(url)
        }
    }
    
    func button(_ action: @escaping () -> Void) -> some View {
        
        Button(action: action) {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.96))
                
                VStack(alignment: .leading) {
                    
                    icon.renderingMode(.original)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        title.text(withConfig: config.title)
                        
                        subTitle.text(withConfig: config.subtitle)
                            .lineLimit(1)
                    }
                }
                .padding(11)
            }
        }
        .buttonStyle(PushButtonStyle())
        .accessibilityIdentifier("buttonOpenNewProduct")
    }
    
    func link(_ url: URL) -> some View {
        
        Link(destination: url) {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.96))
                
                VStack(alignment: .leading) {
                    
                    icon.renderingMode(.original)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        title.text(withConfig: config.title)
                        
                        subTitle.text(withConfig: config.subtitle)
                    }
                }
                .padding(11)
            }
            
        }
        .buttonStyle(PushButtonStyle())
        .accessibilityIdentifier("linkOpenNewProduct")
    }
}

extension NewProductButton {
    
    final class ViewModel: ObservableObject {
        
        let id: String
        let icon: Image
        let title: String
        let subTitle: String
        let tapAction: TapAction
        
        init(
            id: String = UUID().description,
            icon: Image,
            title: String,
            subTitle: String,
            action: @escaping () -> Void
        ) {
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.tapAction = .action(action)
        }
        
        init(
            id: String = UUID().description,
            icon: Image,
            title: String,
            subTitle: String,
            url: URL
        ) {
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.tapAction = .url(url)
        }
    }
}

extension NewProductButton {
    
    enum TapAction {
        
        case action(() -> Void)
        case url(URL)
    }
}

struct PushButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

//MARK: - Preview Content

extension NewProductButton.ViewModel {
    
    static let sample = NewProductButton.ViewModel(id: "CARD", icon: Image(systemName: "rectangle.badge.plus"), title: "Карту", subTitle: "62 дня без %", action: {})
}
