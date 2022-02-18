//
//  PaymentsTaxesSelectCardViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.02.2022.
//

import SwiftUI

struct PaymentsTaxesSelectCardView: View {
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 10) {
           
                Image("card-colored")
                    .resizable()
                    .frame(width: 32, height: 22)
            VStack(alignment: .leading, spacing: 8)  {
                Text("Счет списания")
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
                HStack(alignment: .center, spacing: 10) {
                    Image("card_mastercard_logo")
                        .resizable()
                        .frame(width: 24, height: 15)
                    Text("Standart")
                        .font(Font.custom("Inter-Medium", size: 14))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                    Spacer()
                    Text("645 347")
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                    Button {
                        
                    } label: {
                        Image("chevron-downnew")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }

                }
                
                Text("Номер карты, имя карты")
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
            }
        }
    }
}


struct PaymentsTaxesSelectCardView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTaxesSelectCardView()
        .previewLayout(.fixed(width: 375, height: 90))
    }
}

