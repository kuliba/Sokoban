//
//  QRDocumentsButtonsViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.10.2022.
//

import SwiftUI

extension QRActionButtonsView {
    
    struct ViewModel {
        
        let buttons: [ButtonIconTextView.ViewModel]
    }
    
}

struct QRActionButtonsView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 24) {
                
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

struct QRActionButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        QRActionButtonsView(viewModel: .init(buttons: [.init(icon: .init(image: .ic40SBP, style: .original, background: .circleSmall), title: .init(text: "Из документов", style: .bold), orientation: .horizontal, action: {})]))
    }
}

