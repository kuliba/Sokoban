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
        
        init(currentDate: Date) {
            
            let reportPeriodStart = Date.getStartOfPrevMonth(for: currentDate)
            let reportPeriodEnd = Date.getEndOfMonth(for: reportPeriodStart)
            
            let paymentPeriodStart = Date.getStartOfCurrentMonth(for: currentDate)
            let paymentPeriodEnd = Date.getEndOfMonth(for: currentDate)
            
            let calendar = Calendar.current
            let totalPaymentDays = calendar.numberOfDaysBetween(paymentPeriodStart, and: paymentPeriodEnd)
            let remanPaymentDays = calendar.numberOfDaysBetween(currentDate, and: paymentPeriodEnd)
            let passedPaymentDays = calendar.numberOfDaysBetween(paymentPeriodStart, and: currentDate)
           
            let formatter = DateFormatter.dateAndMonth
 
            self.title = "Отчетный период " + formatter.string(from: reportPeriodStart) + " - " + formatter.string(from: reportPeriodEnd)
            self.dateTitle = "Дата платежа - " + formatter.string(from: paymentPeriodEnd)
            self.remain = "\(remanPaymentDays) дней"
            self.progress = 1.0 - (Double(passedPaymentDays) / Double(totalPaymentDays))
        }
        
        init(title: String, paymentDate: Date, currentDate: Date) {
            
            let paymentPeriodStart = Date.getMonthBack(from: paymentDate)

            let calendar = Calendar.current
            let totalPaymentDays = calendar.numberOfDaysBetween(paymentPeriodStart, and: paymentDate)
            let remanPaymentDays = max(calendar.numberOfDaysBetween(currentDate, and: paymentDate), 0)
            let passedPaymentDays = calendar.numberOfDaysBetween(paymentPeriodStart, and: currentDate)
           
            let formatter = DateFormatter.dateAndMonth
 
            self.title = title
            self.dateTitle = "Дата платежа - " + formatter.string(from: paymentDate)
            self.remain = "\(remanPaymentDays) дней"
            self.progress = Double(passedPaymentDays) / Double(totalPaymentDays)
        }
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

                                                                                      
