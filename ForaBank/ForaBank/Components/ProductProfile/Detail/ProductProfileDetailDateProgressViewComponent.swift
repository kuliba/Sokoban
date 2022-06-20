//
//  ProductProfileDetailDateProgressViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 14.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
        
    struct DateProgressViewModel {
        
        let title: String
        let dateTitle: String
        let remain: String
        let progress: Double
        
        internal init(title: String, dateTitle: String, remain: String, progress: Double) {
            
            self.title = title
            self.dateTitle = dateTitle
            self.remain = remain
            self.progress = progress
        }
        
        init(title: String, paymentDate: Date, currentDate: Date) {
            
            self.title = title
            let dateFormatter = DateFormatter.dateAndMonth
            self.dateTitle = "Дата платежа - " + dateFormatter.string(from: paymentDate)
            
            let calendar = Calendar.current
            let daysBetween = calendar.numberOfDaysBetween(currentDate, and: paymentDate)
            let daysFromMonthStart = calendar.component(.day, from: paymentDate)
            self.remain = "\(daysBetween) дней"
            self.progress = 1.0 - (Double(max(daysBetween, 0)) / Double(daysFromMonthStart))
        }
        
        /*
        enum SubTitleViewModel {
            
            case paid
            case start
            case interval
            case delayCredit
            case mortgage
            case consumer
            
            var subTitle: String {
                
                switch self {
                case .paid: return "Обязательный платеж погашен!\nУ вас нет задолженности"
                case .start: return "Поздравляем 🎉, Вы стали обладателем кредитной карты. Оплачивайте покупки и получайте Кешбэк и скидки от партнеров."
                case .interval: return "Отчетный период \(Date().startOfPreviusDate()) - \(Date().endOfMonth()) "
                case .delayCredit: return "Вносите платеж вовремя"
                case .consumer: return "Очередной платеж по кредиту"
                case .mortgage: return "Очередной платеж по ипотеке"
                }
            }
        }
         */
    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct DateProgressView: View {
        
        var viewModel: ProductProfileDetailView.ViewModel.DateProgressViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                
                HStack {
                    
                    //FIXME: font
                    Text(viewModel.dateTitle)
                        .font(.system(size: 16))
                        .foregroundColor(.textWhite)

                    Spacer()
                    
                    HStack {
                        
                        //FIXME: color
                        Image.ic24HistoryInactive
                            .resizable()
                            .foregroundColor(.gray)
                        .frame(width: 12, height: 12)
                        
                        //FIXME: font
                        Text(viewModel.remain)
                            .font(.system(size: 12))
                            .foregroundColor(.textPlaceholder)
                    }
                }
                
                LineProgressView(progress: .constant(CGFloat(viewModel.progress)))
                    .padding(.top, 4)
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailDateProgressViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileDetailView.DateProgressView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 80))
            
            ProductProfileDetailView.DateProgressView(viewModel: .sampleNormal)
                .previewLayout(.fixed(width: 375, height: 80))
            
            ProductProfileDetailView.DateProgressView(viewModel: .sampleOverdue)
                .previewLayout(.fixed(width: 375, height: 80))
            
        }.background(Color.black)
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.DateProgressViewModel {
    
    static let sample = ProductProfileDetailView.ViewModel.DateProgressViewModel(title: "Отчетный период 1 мая - 31 мая", dateTitle: "Дата платежа - 4 июня", remain: "5 дней", progress: 0.7)
    
    static let sampleNormal = ProductProfileDetailView.ViewModel.DateProgressViewModel(title: "Отчетный период 1 мая - 31 мая", dateTitle: "Дата платежа - 4 июня", remain: "5 дней", progress: 0.3)

    
    static let sampleOverdue = ProductProfileDetailView.ViewModel.DateProgressViewModel(title: "Вносите платеж вовремя", dateTitle: "Дата платежа - 4 июня", remain: "-20 дней", progress: 1.0)
}

                                                                                      
