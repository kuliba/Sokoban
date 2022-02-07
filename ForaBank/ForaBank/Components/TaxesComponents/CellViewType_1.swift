//
//  CellViewType_1.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

extension CellType_1View {
    
    struct ViewModel: Identifiable {
        let id = UUID()
        let logo: Image
        let title: String
        let subTitle: String
        let action: (ViewModel.ID) -> Void
        
    }
    
}

struct CellType_1View {
    
    struct CellType_1: View {
        let viewModel: CellType_1View.ViewModel
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


struct CellType_1View_Previews: PreviewProvider {
    static var previews: some View {
        CellType_1View.CellType_1(viewModel: CellType_1View.ViewModel(logo: Image("qr_Icon"), title: "Title", subTitle: "SubTitle", action: {_ in }))
        .previewLayout(.fixed(width: 375, height: 56))
    }
}
