//
//  QRInfoView.swift
//  ForaBank
//
//  Created by Константин Савялов on 24.10.2022.
//

import SwiftUI

struct QRInfoViewModel {
    
    let icon: Image
    let title: String
    let content: String
    
    internal init(icon: Image, title: String, content: String) {
        self.icon = icon
        self.title = title
        self.content = content
    }
}

struct QRInfoView: View {
    
    let viewModel: QRInfoViewModel
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            viewModel.icon
                .frame(width: 88, height: 88)
            
            Text(viewModel.title)
                .foregroundColor(Color.textSecondary)
                .font(Font.textH4SB16240())
            
            Text(viewModel.content)
                .foregroundColor(Color.textSecondary)
                .font(Font.buttonSmallM14160())
            
            Spacer()
        }
    }
}

//MARK: - Preview

struct QRInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        QRInfoView(viewModel: .init(icon: .ic24AlertCircle,
                                    title: "Сканировать QR-код",
                                    content: "Наведите камеру телефона на QR-код, и приложение автоматически его считает.\n\n Перед оплатой проверьте, что все поля заполнены правильно.\n\n Чтобы оплатить квитанцию, сохраненнуюв телефоне, откройте ее с помощью кнопки \"Из файла\", и отсканируйте QR-код."))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
