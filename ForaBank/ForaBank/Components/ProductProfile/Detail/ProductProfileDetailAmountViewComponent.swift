//
//  ProductProfileDetailAmountViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 16.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
    
    struct AmountViewModel: Identifiable {

        let id: UUID
        let title: String
        let value: String
        let prefix: Prefix?
        let postfix: Postfix?
        let backgroundColor: Color?
        
        internal init(id: UUID = UUID(), title: String, value: String, prefix: Prefix? = nil, postfix: Postfix? = nil, backgroundColor: Color? = nil) {
            self.id = id
            self.title = title
            self.value = value
            self.prefix = prefix
            self.postfix = postfix
            self.backgroundColor = backgroundColor
        }
        
        enum Prefix {
            
            case legend(Color)
        }
        
        enum Postfix {
            
            case value(String)
            case info(color: Color, action: () -> Void)
            case checkmark
        }
    }
    
    /*
     enum Kind: Hashable {
         
         case debt
         case available
         case ownfunds
         case limit
         case repaid
         case creditAmount
         
         var title: String {
             
             switch self {
             case .debt: return "Задолженность"
             case .available: return "Доступно"
             case .ownfunds: return "Собственные средства"
             case .limit: return "Кредитный лимит"
             case .repaid: return "Уже погашено"
             case .creditAmount: return "Сумма кредита"
                 
             }
         }
     }
     */
    /*
     enum Title: Hashable {
         
         case minimal
         case preferential
         case totalDebt
         case available
         case delay
         case minimalCredit
         
         var title: String {
             
             switch self {
                 
             case .minimal: return "Минимальный платеж"
             case .preferential: return "Льготный платеж"
             case .totalDebt: return "Общая задолженность"
             case .available: return "Доступно"
             case .delay: return "Включая просрочку"
             case .minimalCredit: return "Внести платеж"
             }
         }
     }
     */
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct AmountView: View {
        
        let viewModel: ProductProfileDetailView.ViewModel.AmountViewModel
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 8).foregroundColor(viewModel.backgroundColor ?? .clear)
                    .padding(.horizontal, -8)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(viewModel.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                        
                        HStack(spacing: 8) {
                            
                            if let prefix = viewModel.prefix {
                                
                                switch prefix {
                                case let .legend(color):
                                    Circle()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(color)
                                }
                            }
                            
                            Text(viewModel.value)
                                .font(.textH4M16240())
                                .foregroundColor(.textWhite)
                            
                            if let postfix = viewModel.postfix {
                                
                                switch postfix {
                                case .value(let value):
                                    Text("/ \(value)")
                                        .font(.textBodySR12160())
                                        .foregroundColor(.textPlaceholder)
                                    
                                case .info(let color, let action):
                                    Button(action: action) {
                                        ZStack {
                                            
                                            Color.mainColorsBlack
                                                .frame(width: 24, height: 24)
                                            
                                            Image.ic24AlertCircle
                                                .resizable()
                                                .frame(width: 14, height: 14)
                                                .foregroundColor(color)
                                            
                                        }.offset(x: -8, y: 0)
                                    }
                                    
                                case .checkmark:
                                    Image.ic24Check
                                        .foregroundColor(.textWhite)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }

                .padding(.vertical, 5)
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailAmountViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ZStack {
            
            Color.mainColorsBlack
            
            VStack(alignment: .leading) {
                
                ProductProfileDetailView.AmountView(viewModel: .sample)

                ProductProfileDetailView.AmountView(viewModel: .sampleBackground)
                
                ProductProfileDetailView.AmountView(viewModel: .sampleLegend)
                    
                ProductProfileDetailView.AmountView(viewModel: .sampleLegendValue)
     
                ProductProfileDetailView.AmountView(viewModel: .sampleCheckmark)
                
                ProductProfileDetailView.AmountView(viewModel: .sampleInfo)
                
            }.padding(.horizontal, 20)
            
        }.previewLayout(.fixed(width: 300, height: 500))
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.AmountViewModel {
    
    static let sample = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Минимальный платеж", value: "3 417.01 ₽")
    
    static let sampleLegend = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Задолженность", value: "60 056 ₽", prefix: .legend(.textPlaceholder))
    
    static let sampleLegendValue = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Уже погашено", value: "434 056,77 ₽", prefix: .legend(.mainColorsRed), postfix: .value("434 056,77 ₽"))
    
    static let sampleCheckmark = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Минимальный платеж", value: "Внесен", postfix: .checkmark)
    
    static let sampleInfo = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Включая просрочку", value: "367.25 ₽", postfix: .info(color: .mainColorsRed, action: {}))
    
    static let sampleBackground = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Минимальный платеж", value: "3 417.01 ₽", backgroundColor: .mainColorsBlackMedium)
}


