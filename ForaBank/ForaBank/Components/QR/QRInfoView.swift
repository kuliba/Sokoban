//
//  QRInfoViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 24.10.2022.
//

import SwiftUI

struct QRInfoViewModel {
    
    struct ViewModel: Identifiable {
        
        var id = UUID()
        let icon: Image
        let title: String
        let content: [String]
        
        internal init(icon: Image, title: String, content: String) {
            self.icon = icon
            self.title = title
            let contentArray = content.components(separatedBy: ".")
            self.content = contentArray
        }
    }
}

struct QRInfoViewComponent: View {
    
    let viewModel: QRInfoViewModel.ViewModel
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            ZStack {
            Circle()
                .foregroundColor(.mainColorsGrayLightest)
                .frame(width: 88, height: 88)
            
            viewModel.icon
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.iconBlack)
            }
            
            Text(viewModel.title)
                .foregroundColor(Color.textSecondary)
                .font(Font.textH4SB16240())
            
            VStack {
                ForEach(viewModel.content, id: \.self) { content in
                    Text(content)
                        .foregroundColor(Color.textSecondary)
                        .font(Font.buttonSmallM14160())
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

//MARK: - Preview

struct QRInfoViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        QRInfoViewComponent(viewModel: .init(icon: .ic24AlertCircle,
                                    title: "Сканировать QR-код",
                                    content: "Наведите камеру телефона на QR-код, и приложение автоматически его считает. Перед оплатой проверьте, что все поля заполнены правильно. Чтобы оплатить квитанцию, сохраненнуюв телефоне, откройте ее с помощью кнопки \"Из файла\", и отсканируйте QR-код."))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
