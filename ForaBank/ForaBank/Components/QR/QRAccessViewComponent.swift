//
//  QRAccessViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.12.2022.
//

import SwiftUI

struct QRAccessViewModel {
    
    class ViewModel: Identifiable {
        
        var id = UUID()
        let icon: Image
        let title: String
        let content: String
        @Published var clouseButton: ButtonSimpleView.ViewModel
        
        internal init(icon: Image, title: String, content: String, clouseButton: ButtonSimpleView.ViewModel) {
            self.icon = icon
            self.title = title
            self.content = content
            self.clouseButton = clouseButton
        }
        
        convenience init(input: Input, closeAction: @escaping () -> Void) {
            let clouseButton = ButtonSimpleView.ViewModel(title: "Перейти в настройки", style: .red, action: closeAction)
            
            self.init(icon: input.result.2, title: input.result.0,
                      content: input.result.1,
                      clouseButton: clouseButton)
        }
        
        enum Input {
            case photo
            case camera
            
            var result: (String, String, Image) {
                switch self {
                case .photo: return ("Разрешите доступ к фото", "Сможете сканировать файлы/документы с QR-кодом", Image.ic24Image)
                case .camera: return ("Разрешите доступ к камере", "Сможете оплачивать по QR-коду и сканировать карты", Image.ic24Camera)
                }
            }
        }
    }
}

struct QRAccessViewComponent: View {
    
    let viewModel: QRAccessViewModel.ViewModel
    
    var body: some View {
        
        VStack {
            
            ZStack {
            Circle()
                .foregroundColor(.mainColorsGrayLightest)
                .frame(width: 88, height: 88)
            
            viewModel.icon
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundColor(.iconGray)
            }

            Text(viewModel.title)
                .foregroundColor(Color.textSecondary)
                .font(Font.textH4SB16240())
            
            Text(viewModel.content)
                .foregroundColor(Color.textSecondary)
                .font(Font.buttonSmallM14160())
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.vertical, 5)
            
            ButtonSimpleView(viewModel: viewModel.clouseButton)
                .frame(height: 48)
                .padding(.vertical, 50)
        }.padding(20)
    }
}

//MARK: - Preview

struct QRAccessViewComponent_Previews: PreviewProvider {
    
    static var clouseButton = ButtonSimpleView.ViewModel(title: "Перейти в настройки", style: .red, action: {})
    
    static var previews: some View {
        
        QRAccessViewComponent(viewModel: .init(icon: .ic24AlertCircle,
                                               title: "Разрешите доступ к фото",
                                               content: "Сможете сканировать файлы/документы с QR-кодом",
                                               clouseButton: Self.clouseButton
                              ))
        .previewLayout(.fixed(width: 100, height: 100))
    }
}

