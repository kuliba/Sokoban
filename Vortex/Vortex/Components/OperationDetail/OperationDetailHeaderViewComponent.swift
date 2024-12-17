//
//  OperationDetailHeaderViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 30.06.2022.
//

import SwiftUI

//MARK: - View Model

extension OperationDetailViewModel {
    
    struct HeaderViewModel {
        
        let logo: Image?
        let status: StatusViewModel?
        let title: String
        let category: String?
        let amountStatusImage: Image?
        
        internal init(
            logo: Image?,
            status: OperationDetailViewModel.StatusViewModel?,
            amountStatusImage: Image?,
            title: String,
            category: String?
        ) {
            self.logo = logo
            self.status = status
            self.amountStatusImage = amountStatusImage
            self.title = title
            self.category = category
        }
        
        init(statement: ProductStatementData, model: Model) {
            
            let image = model.images.value[statement.md5hash]?.image
            
            let status: StatusViewModel? = {
                
                switch statement.operationType {
                    
                case .credit, .debit:
                    return .success
                    
                case .creditPlan, .debitPlan:
                    return .processing
                    
                case .creditFict, .debitFict:
                    return .reject
                    
                case .open, .demandDepositFromAccount, .unknown:
                    return nil
                }
            }()
            
            let amountStatusImage: Image? = {
                
                switch statement.operationType {
                    
                case .creditPlan, .debitPlan:
                    return .ic16Waiting
                    
                case .creditFict, .debitFict:
                    return .ic16Denied
                    
                case .credit, .debit, .open, .demandDepositFromAccount, .unknown:
                    return nil
                }
            }()

            switch statement.paymentDetailType {
                
            case .insideBank:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.merchant, category: statement.groupName)
                
            case .betweenTheir:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.groupName, category: "Переводы")
                
            case .otherBank:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.merchant, category: statement.groupName)
                
            case .contactAddressless, .direct:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.groupName, category: nil)
                
            case .externalIndivudual, .externalEntity:
             
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.groupName, category: nil)
                
            case .housingAndCommunalService, .insideOther, .internet, .mobile:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.merchant, category: "\(statement.groupName)")
                
            case .outsideCash:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.groupName, category: "Прочие")
                
            case .outsideOther:
                if let mcc = statement.mcc {
                    
                    self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.merchant, category: "\(statement.groupName) (MCC \(mcc))")
                } else {
                    
                    self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.merchant, category: "\(statement.groupName)")
                }
                
            case .sfp:
                self.init(logo: Image("Operation Type SFP Icon"), status: status, amountStatusImage: amountStatusImage, title: statement.groupName, category: nil)
                
            case .transport:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.merchant, category: "\(statement.groupName)")
                
            case .c2b:
                self.init(logo: Image("sbpindetails"), status: statement.isReturn ? .purchase_return : .success, amountStatusImage: amountStatusImage, title: "\(statement.groupName)", category: nil)
                
            case .sberQRPayment:
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: "\(statement.groupName)", category: nil)
                
            default:
                //FIXME: taxes
                self.init(logo: image, status: status, amountStatusImage: amountStatusImage, title: statement.merchant, category: "\(statement.groupName)")
            }
        }
    }
}

//MARK: - View

extension OperationDetailView {
    
    struct HeaderView: View {
        
        let viewModel: OperationDetailViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                ZStack(alignment: .topTrailing) {
                    
                    viewModel.logo?
                        .resizable()
                        .frame(width: 64, height: 64)
                    
                    if let image = viewModel.amountStatusImage {
                        image
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.trailing, -4)
                    }
                }
                
                if let status = viewModel.status {
                    
                    Text(status.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: status.colorHex))
                        .padding(.top, 24)
                }
                
                Text(viewModel.title) // merchantName/Rus
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.top, 12)
                    .padding(.horizontal, 24)
                
                if let category = viewModel.category {
                    
                    Text(category)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
        }
    }
}

//MARK: - Preview

struct OperationDetailHeaderViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperationDetailView.HeaderView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension OperationDetailViewModel.HeaderViewModel {
    
    static let sample = OperationDetailViewModel.HeaderViewModel(logo: .ic16Denied, status: .processing, amountStatusImage: .ic16Waiting, title: "Перевод по реквизитам", category: nil)
}
