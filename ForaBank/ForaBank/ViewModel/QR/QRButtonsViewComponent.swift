//
//  QRButtonsViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 24.10.2022.
//

import SwiftUI

extension QRButtonsView {
    
    struct ViewModel {
        
        let buttons: [ButtonIconTextView.ViewModel]
    }
    
}

struct QRButtonsView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Выберите документ")
                ForEach(viewModel.buttons) { buttonViewModel in
                    
                    ButtonIconTextView(viewModel: buttonViewModel)
                }
            }
            
            Spacer()
        }
        .padding()
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
}

struct QRButtonsViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        QRButtonsView(viewModel: .init(buttons: [.init(icon: .init(image: .ic40SBP, style: .original, background: .circleSmall), title: .init(text: "Фото", style: .bold), orientation: .horizontal, action: {})]))
    }
}

