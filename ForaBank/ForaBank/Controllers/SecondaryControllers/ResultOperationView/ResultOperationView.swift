//
//  ResultOperationView.swift
//  ForaBank
//
//  Created by Дмитрий on 15.12.2021.
//

import SwiftUI

struct ResultOperationView: View {
    
    var body: some View {
        
        VStack{
            Image.ic16Waiting
            Text("Перевод отменен!")
            Text("Время на подтверждение перевода вышло")
            Text("1000 Р.")
            Image("sbp-long")
            Button("На главный") {
                
            }

        }
    }
}

struct ResultOperationView_Previews: PreviewProvider {
    static var previews: some View {
        ResultOperationView()
    }
}
