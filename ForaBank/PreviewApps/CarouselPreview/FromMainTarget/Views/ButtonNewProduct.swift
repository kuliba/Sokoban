import SwiftUI

struct ButtonNewProduct: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        switch viewModel.tapActionType {
        case let .action(action):
            Button(action: action) {
                
                ZStack(alignment: .leading) {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    VStack(alignment: .leading) {
                        
                        viewModel.icon
                            .renderingMode(.original)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text(viewModel.title)
                                .font(Font.custom("Inter-Medium", size: 14.0))
                                .foregroundColor(.textSecondary)
                            
                            Text(viewModel.subTitle)
                                .font(Font.custom("Inter-Medium", size: 14.0))
                                .foregroundColor(.textPlaceholder)
                                .lineLimit(1)
                        }
                        
                    }.padding(11)
                }

            }
            .buttonStyle(PushButtonStyle())
            .accessibilityIdentifier("buttonOpenNewProduct")
            
        case let .url(url):
            
            Link(destination: url) {
                
                ZStack(alignment: .leading) {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    VStack(alignment: .leading) {
                        
                        viewModel.icon
                            .renderingMode(.original)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text(viewModel.title)
                                .font(Font.custom("Inter-Medium", size: 14.0))
                                .foregroundColor(.textSecondary)
                            
                            Text(viewModel.subTitle)
                                .font(Font.custom("Inter-Medium", size: 14.0))
                                .foregroundColor(.textPlaceholder)
                                .lineLimit(1)
                        }
                        
                    }.padding(11)
                }
                
            }
            .buttonStyle(PushButtonStyle())
            .accessibilityIdentifier("linkOpenNewProduct")
        }
    }
}

extension ButtonNewProduct {
    
    class ViewModel: Identifiable, ObservableObject {
        
        let id: String
        let icon: Image
        let title: String
        @Published var subTitle: String
        let tapActionType: TapActionType
        
        enum TapActionType {
            
            case action(() -> Void)
            case url(URL)
        }
        
        init(id: String = UUID().description, icon: Image, title: String, subTitle: String, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.tapActionType = .action(action)
        }
        
        init(id: String = UUID().description, icon: Image, title: String, subTitle: String, url: URL) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.tapActionType = .url(url)
        }
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

extension ButtonNewProduct.ViewModel {
    
    static let sample =  ButtonNewProduct.ViewModel.init(id: "CARD", icon: Image("ic24NewCardColor"), title: "Карту", subTitle: "62 дня без %", action: {})
    
//    static let sampleAccount =  ButtonNewProduct.ViewModel.init(id: "ACCOUNT", icon: .ic24FilePluseColor, title: "Счет", subTitle: "Бесплатно", action: {})
//    
//    static let sampleEmptySubtitle =  ButtonNewProduct.ViewModel.init(id: "CARD", icon: .ic24NewCardColor, title: "Карту", subTitle: "", action: {})
//    
//    static let sampleLongSubtitle =  ButtonNewProduct.ViewModel.init(id: "CARD", icon: .ic24NewCardColor, title: "Карту", subTitle: "13,08 % годовых", action: {})
}
