//
//  PaymentsTaxesView.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

struct PaymentsFNSView: View {
    
    @ObservedObject var viewModel: PaymentTaxesListViewModel
    @Environment(\.presentationMode) var presentation
    @State var showModal =  false

    var body: some View {
        
        if #available(iOS 14.0, *) {
            NavigationView {
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(viewModel.items) {item in
                                
                                NavigationLink {
                                   // PaymentsTaxesFSSPView(viewModel: .init(Model.shared))
                                    
                                } label: {
                                    HStack (alignment: .center, spacing: 10) {
                                        item.item
                                        Spacer()
                                    }
                                }
                            }
                        }
                    } .padding(.top, 10)
                        .padding(.horizontal, 15)
                }
                .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading:
                                        Image("back_button")
                                        .renderingMode(.template)
                                        .foregroundColor(.black)
                                    
                                        .onTapGesture {
                    self.presentation.wrappedValue.dismiss()
                }, trailing: Image("qr_Icon")
                                        .renderingMode(.template)
                                        .foregroundColor(.black)  )
                
            }
            .fullScreenCover(isPresented: $showModal) {
               // PaymentsTaxesFSSPView(viewModel: .init(Model.shared))
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct PaymentsFNSView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsFNSView(viewModel: .init(Model.shared))
    }
}

