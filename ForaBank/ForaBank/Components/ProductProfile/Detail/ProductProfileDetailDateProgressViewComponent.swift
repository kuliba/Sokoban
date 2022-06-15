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
        let remain: String
        let progress: Double
        
        internal init(title: String, remain: String, progress: Double) {
            
            self.title = title
            self.remain = remain
            self.progress = progress
        }
        
        init(paymentDate: Date, currentDate: Date) {
            
            let dateFormatter = DateFormatter.dateAndMonth
            self.title = "Дата платежа - " + dateFormatter.string(from: paymentDate)
            
            let calendar = Calendar.current
            let daysBetween = calendar.numberOfDaysBetween(currentDate, and: paymentDate)
            let daysFromMonthStart = calendar.component(.day, from: paymentDate)
            self.remain = "\(daysBetween) дней"
            self.progress = 1.0 - (Double(max(daysBetween, 0)) / Double(daysFromMonthStart))
        }

    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct DateProgressView: View {
        
        var viewModel: ProductProfileDetailView.ViewModel.DateProgressViewModel
        
        var body: some View {
            
            VStack(spacing: 12) {
                
                HStack {
                    
                    Text(viewModel.title)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    HStack {
                        
                        Image.ic24HistoryInactive
                            .resizable()
                            .foregroundColor(.gray)
                        .frame(width: 12, height: 12)
                        
                        Text(viewModel.remain)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                GeometryReader { geometry in
                    
                    ZStack() {
                        
                        Capsule()
                            .stroke(Color.textPrimary, lineWidth: 1)
                            .frame(height: 6)
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: (geometry.size.width - 44) / 39) {
                            
                            ForEach(0..<40) { _ in
                                
                                Capsule()
                                    .frame(width: 1, height: 2)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        
                        Capsule()
                            .fill(LinearGradient(
                                gradient: .init(colors: [Color(hex: "22C183"), Color(hex: "FFBB36") ,Color(hex: "FF3636")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .padding(2)
                            .clipShape(ClipArea(width: geometry.size.width * viewModel.progress))
  
                    }.frame(height: 6)
                }
            }
        }
    }
}

fileprivate struct ClipArea: Shape {
    
    let width: CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: width, y: rect.minY))
        path.addLine(to: CGPoint(x: width, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

//MARK: - Preview

struct ProductProfileDetailDateProgressViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileDetailView.DateProgressView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 60))
            
            ProductProfileDetailView.DateProgressView(viewModel: .sampleNormal)
                .previewLayout(.fixed(width: 375, height: 60))
            
            ProductProfileDetailView.DateProgressView(viewModel: .sampleOverdue)
                .previewLayout(.fixed(width: 375, height: 60))
            
        }.background(Color.black)
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.DateProgressViewModel {
    
    static let sample = ProductProfileDetailView.ViewModel.DateProgressViewModel(title: "Дата платежа - 4 июня", remain: "5 дней", progress: 0.7)
    
    static let sampleNormal = ProductProfileDetailView.ViewModel.DateProgressViewModel(paymentDate: Date.date(year: 2022, month: 6, day: 28), currentDate: Date.date(year: 2022, month: 6, day: 10))
    
    static let sampleOverdue = ProductProfileDetailView.ViewModel.DateProgressViewModel(paymentDate: Date.date(year: 2022, month: 6, day: 10), currentDate: Date.date(year: 2022, month: 6, day: 25))
}
                                                                
fileprivate extension Date {
    
    static func date(year: Int, month: Int, day: Int) -> Date {
        
        let components = DateComponents(year: year, month: month, day: day, hour: 5)
        return Calendar.current.date(from: components)!
    }
}
                                                                                      
