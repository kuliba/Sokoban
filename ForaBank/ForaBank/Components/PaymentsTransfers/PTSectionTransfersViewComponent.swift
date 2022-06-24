//
//  PTSectionTransfersViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import Combine

//MARK: Section ViewModel

extension PTSectionTransfersView {
    
    class ViewModel: PaymentsTransfersSectionViewModel {
     
        @Published
        var transfersButtons: [TransfersButtonVM]

        override var type: PaymentsTransfersSectionType { .transfers }
        
        struct TransfersButtonVM: Identifiable {
            var id: String { type.rawValue }
            
            let type: TransfersButtonType
            var title: String { type.apearance.title }
            var image: String { type.apearance.image }
            let action: () -> Void
        }
        
        enum TransfersButtonType: String, CaseIterable {
            case byPhoneNumber
            case betweenSelf
            case abroad
            case anotherCard
            case byBankDetails
            
            var apearance: (title: String, image: String)  {
                switch self {
                case .byPhoneNumber: return ("По номеру\nтелефона", "ic48Telephone")
                case .betweenSelf: return ("Между\nсвоими", "ic48BetweenTheir")
                case .abroad: return ("За рубеж\nи по РФ", "ic48Abroad")
                case .anotherCard: return ("На другую\nкарту", "ic48AnotherCard")
                case .byBankDetails: return ("По\nреквизитaм", "ic48BankDetails")
                }
            }
        }
        
        override init() {
            
            self.transfersButtons = []
            super.init()
            self.transfersButtons = TransfersButtonType.allCases.map { item in
                TransfersButtonVM(type: item,
                                  action: { self.action.send(PTSectionTransfersViewAction
                                    .ButtonTapped
                                    .Transfer(type: item)) })
            }
        }
        
        init(transfersButtons: [TransfersButtonVM]) {
            
            self.transfersButtons = transfersButtons
            super.init()
        }
    }
}

//MARK: Section View

struct PTSectionTransfersView: View {
    
    @ObservedObject
    var viewModel: ViewModel
    
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
        let viewModel: ViewModel.TransfersButtonVM
        
        var body: some View {
            ZStack(alignment: .bottom){
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 78, height: 60)
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
            .frame(width: 104 , height: 150, alignment: .top)
        }
    }
    
}

//MARK: - Action PTSectionTransfersViewAction

enum PTSectionTransfersViewAction {

    enum ButtonTapped {

        struct Transfer: Action {

            let type: PTSectionTransfersView.ViewModel.TransfersButtonType
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
