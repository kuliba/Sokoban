//
//  PTSectionTransfersViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI

//MARK: Section ViewModel

extension PTSectionTransfersView {
    
    class SectionViewModel: PaymentsTransfersSectionViewModel {
     
        @Published
        var transfersButtons: [TransfersButtonVM]

        override var type: PaymentsTransfersSectionType { .transfers }
        
        struct TransfersButtonVM: Identifiable {
            var id: String { title }
            
            let title: String
            let image: String
            let action: () -> Void
        }
        
        override init() {
            self.transfersButtons = Self.transfersButtonsData
            super.init()
        }
        
        init(transfersButtons: [TransfersButtonVM]) {
            self.transfersButtons = transfersButtons
            super.init()
        }
        
        static let transfersButtonsData: [TransfersButtonVM] = {
            [
            .init(title: "По номеру\nтелефона", image: "ic48Telephone", action: {}),
            .init(title: "Между\nсвоими", image: "ic48BetweenTheir", action: {}),
            .init(title: "За рубеж\nи по РФ", image: "ic48Abroad", action: {}),
            .init(title: "На другую\nкарту ", image: "ic48AnotherCard", action: {}),
            .init(title: "По\nреквизитaм", image: "ic48BankDetails", action: {})
            ]
        }()
    }
}

//MARK: Section View

struct PTSectionTransfersView: View {
    
    @ObservedObject
    var viewModel: SectionViewModel
    
    var body: some View {
        Text(viewModel.title) 
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.textH2SB20282())
            .foregroundColor(.textSecondary)
            .padding(.top, 30)
            .padding(.bottom, 14)
            .padding(.leading, 20)
    
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
        
                ForEach(viewModel.transfersButtons) { buttonVM in
                    TransfersButtonView(viewModel: buttonVM)
                }
                Spacer(minLength: 15)
            }.padding(.leading, 20)
        }
    }
    
}

//MARK: - TransfersButtonView

extension PTSectionTransfersView {
    
    struct TransfersButtonView: View {
        let viewModel: SectionViewModel.TransfersButtonVM
        
        var body: some View {
            ZStack(alignment: .bottom){
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 80, height: 60)
                    .shadow(color: .mainColorsBlackMedium.opacity(0.4), radius: 12, y: 6)
                
                Button(action: viewModel.action, label: {
                    ZStack {
                        VStack(spacing: 16) {
                            
                            Image(viewModel.image)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 48, height: 48)
                                .padding(.top, 10)
                            
                            HStack {
                                Text(viewModel.title)
                                    .font(.textBodyMR14200())
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 12)
                                Spacer()
                            }
                            
                        }.frame(width: 104)
                    }
                })
                .frame(width: 104, height: 124)
                .background(Color.mainColorsBlackMedium)
                .cornerRadius(12)
            }
        }
    }
    
}

//MARK: - Preview

struct PTSectionTransfersView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PTSectionTransfersView(viewModel: .init())
            .previewLayout(.fixed(width: 380, height: 190))
            .previewDisplayName("Section Transfers")
    }
}
