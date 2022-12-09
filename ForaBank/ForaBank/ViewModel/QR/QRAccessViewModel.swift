//
//  QRAccessViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.12.2022.
//

import SwiftUI
import Combine

struct QRAccessViewModel {
    
    struct ViewModel {
        
        let icon: Image
        let title: String
        let content: String
        let buttonTitle: String
        
        internal init(icon: Image, title: String, content: String, buttonTitle: String) {
            self.icon = icon
            self.title = title
            self.content = content
            self.buttonTitle = buttonTitle
        }
    }
}

struct QRAccessViewComponent: View {
    
    let viewModel: QRAccessViewModel.ViewModel
    
    var body: some View {
        
        VStack {
            
            viewModel.icon
                .frame(width: 88, height: 88)
            
            Text(viewModel.title)
                .foregroundColor(Color.textSecondary)
                .font(Font.textH4SB16240())
            
            Text(viewModel.content)
                .foregroundColor(Color.textSecondary)
                .font(Font.buttonSmallM14160())
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 5)
        }
    }
}

//MARK: - Preview

struct QRAccessViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        QRAccessViewComponent(viewModel: .init(icon: .ic24AlertCircle,
                                             title: "Разрешите доступ к фото",
                                               content: "Сможете сканировать файлы/документы с QR-кодом", buttonTitle: "Перейти в настройки"))
        .previewLayout(.fixed(width: 100, height: 100))
    }
}

