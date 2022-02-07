//
//  ParentCellView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.02.2022.
//

import SwiftUI

extension ParentCellView {
   
    struct ViewModel {
        
        let logo: Image
        let title: String
        let action: () -> Void
    }
    
}

struct ParentCellView: View {
    
    var body: some View {
        HStack(spacing: 10) {
            
                 Image("qr_Icon")
                .resizable()
                .frame(width: 64, height: 64)
            
                Text("Title")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.black)
            
        } .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .leading
          )
    }
}


struct ParentCellView_Previews: PreviewProvider {
    static var previews: some View {
        ParentCellView()
        .previewLayout(.fixed(width: 375, height: 56))
    }
}

