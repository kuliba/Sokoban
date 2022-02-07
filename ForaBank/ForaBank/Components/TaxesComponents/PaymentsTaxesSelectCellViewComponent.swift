//
//  ParentCellView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.02.2022.
//

import SwiftUI

extension PaymentsTaxesSelectCellViewComponent {
    
    struct ViewModel: Identifiable {
        let id = UUID()
        let logo: Image
        let title: String
        let subTitle: String
        let action: (ViewModel.ID) -> Void
        
    }
    
    struct ButtonViewModel {
        
        let icon: Image
        let action: () -> Void
    }
    
}

struct PaymentsTaxesSelectCellViewComponent {
    
    struct PaymentsTaxesSelectCell: View {
        let viewModel: PaymentsTaxesSelectCellViewComponent.ViewModel
        let buttonViewModel:PaymentsTaxesSelectCellViewComponent.ButtonViewModel
        @State private var showDetails = false
        var body: some View {
            HStack(spacing: 10) {
                
                viewModel.logo
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 10)  {
                    Text(viewModel.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.black)
                    Text(viewModel.subTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.gray)
                    
                }
                Spacer()
                Button {
                    showDetails.toggle()
                } label: {
                    buttonViewModel.icon
                } .frame(width: 30, height: 30)
                    .padding(.trailing, 15)

                if showDetails {
                    
                }
                
            } .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .leading
            )
        }
    }
}


struct ParentCellView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTaxesSelectCellViewComponent.PaymentsTaxesSelectCell(viewModel: PaymentsTaxesSelectCellViewComponent.ViewModel(logo: Image("fora_white_back_bordered"),
                                                                                                                               title: "Title",
                                                                                                                        subTitle: "SubTitle",         action: { _ in }),
                                                             buttonViewModel: PaymentsTaxesSelectCellViewComponent.ButtonViewModel(icon: Image("chevron-downnew"), action:{}))
            .previewLayout(.fixed(width: 375, height: 56))
    }
}

