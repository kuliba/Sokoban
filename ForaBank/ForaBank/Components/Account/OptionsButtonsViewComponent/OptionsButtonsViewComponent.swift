//
//  OptionsButtonsViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 10.08.2022.
//

import SwiftUI

extension OptionsButtonsViewComponent {
    
    struct ViewModel {
        
        let buttons: [ButtonIconTextView.ViewModel]
    }
    
}

struct OptionsButtonsViewComponent: View {
    
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

struct OptionsButtonsViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        OptionsButtonsViewComponent(viewModel: .init(buttons: [.init(icon: .init(image: .ic40SBP, style: .original, background: .circleSmall), title: .init(text: "С моего счета в другом банке", style: .bold), orientation: .horizontal, action: {})]))
    }
}
