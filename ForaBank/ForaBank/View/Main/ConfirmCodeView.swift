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
    
    var body: some View {
        
        PinCodeUI.ConfirmView(
            viewModel: .init(handler: {_, _ in }),
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
        phoneNumber: String = "+1...78",
        reset: @escaping () -> Void = { },
        hasDefaultBackButton: Bool = false,
        previewDisplayName: String
    ) -> some View {
        
        NavigationView{
            
            ConfirmCodeView(
                phoneNumber: phoneNumber,
                reset: reset,
                hasDefaultBackButton: hasDefaultBackButton
            )
        }
        .previewDisplayName(previewDisplayName)
        .previewLayout(.sizeThatFits)
    }
}
