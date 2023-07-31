//
//  ConfirmCodeView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.07.2023.
//

import PinCodeUI
import SwiftUI

struct ConfirmCodeView: View {
    
    let phoneNumber: String
    let reset: () -> Void
    var hasDefaultBackButton: Bool = false
    var handler: (String, @escaping (Bool) -> Void) -> Void
    
    var body: some View {
        
        PinCodeUI.ConfirmView(
            viewModel: .init(handler: handler),
            phoneNumber: phoneNumber
        )
        .if(!hasDefaultBackButton) { view in
            
            view
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Button(
                            action: reset,
                            label: {
                                Image.ic24ChevronLeft
                                    .aspectRatio(contentMode: .fit)
                            }
                        )
                        .buttonStyle(.plain)
                    }
                }
        }
    }
}

struct ConfirmCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(
                hasDefaultBackButton: true,
                previewDisplayName: "Default back button"
            )

            preview(
                previewDisplayName: "Custom back button"
            )
        }
    }
    
    private static func preview (
        phoneNumber: String = "71234567899",
        reset: @escaping () -> Void = { },
        hasDefaultBackButton: Bool = false,
        previewDisplayName: String
    ) -> some View {
        
        NavigationView{
            
            ConfirmCodeView(
                phoneNumber: phoneNumber,
                reset: reset,
                hasDefaultBackButton: hasDefaultBackButton,
                handler: { _, _ in }
            )
        }
        .previewDisplayName(previewDisplayName)
        .previewLayout(.sizeThatFits)
    }
}
