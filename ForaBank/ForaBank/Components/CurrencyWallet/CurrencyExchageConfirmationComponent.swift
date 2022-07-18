//
//  CurrencyExchangeConfirmationComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 17.07.2022.
//

import SwiftUI
import Combine


//MARK: - ViewModel

extension CurrencyExchangeConfirmationView {
    
    class ViewModel: ObservableObject {
        
        @Published var tableVM: TableViewModel?
        @Published private(set) var imageVM: ImageViewModel?
        @Published private(set) var textVM: TextViewModel?
        
        
        var state: ConfirmationState {
            didSet {
                setupSections(for: state)
            }
        }
        
        enum ConfirmationState {
            
            case nothing
            case needConfirm
            case successImage
            case fullSuccess
            case error
            case waiting
        }
        
        init(state: ConfirmationState,
             tableVM: TableViewModel?,
             imageVM: ImageViewModel?,
             textVM: TextViewModel?) {
            
            self.state = state
            self.imageVM = imageVM
            self.tableVM = tableVM
            self.textVM = textVM
        }
        
        init(tableVM: TableViewModel?) {
            
            self.state = .nothing
            self.tableVM = tableVM
            
            setupSections(for: self.state)
        }
        
        class TableViewModel: ObservableObject {
            
            let sum: String
            let commission: String
            let sumCurrency: String
            
            init(sum: String, commission: String, sumCurrency: String) {
                self.sum = sum
                self.commission = commission
                self.sumCurrency = sumCurrency
            }
            
        }
        
        struct ImageViewModel {
            
            let image: Image
        }
        
        struct TextViewModel {
            
            let text: String
            let value: String
        }
        
        private func setupSections(for state: ConfirmationState) {
            
            switch state {
            
            case .nothing:
                self.tableVM = nil
                self.imageVM = nil
                self.textVM = nil
                
            case .needConfirm:
                self.imageVM = nil
                self.textVM = nil
                
            case .successImage:
                self.imageVM = .init(image: Image("Done"))
                self.textVM = nil
            
            case .fullSuccess:
                
                guard let tableVM = tableVM else { return }
                self.imageVM = .init(image: Image("Done"))
                self.textVM = .init(text: "Успешный перевод", value: tableVM.sum)
            
            case .error:
                guard let tableVM = tableVM else { return }
                self.imageVM = .init(image: Image("Denied"))
                self.textVM = .init(text: "Операция неуспешна!", value: tableVM.sum)
            
            case .waiting:
                guard let tableVM = tableVM else { return }
                self.imageVM = .init(image: Image("waiting"))
                self.textVM = .init(text: "Операция в обработке!", value: tableVM.sum)
            }
            
        }
        
    }
}

//MARK: - View

struct CurrencyExchangeConfirmationView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        VStack {
                
            if let tableVM = viewModel.tableVM {
                
                TableView(viewModel: tableVM).padding(.bottom, 32)
            }
            
            if let imageVM = viewModel.imageVM {
                
                ImageView(viewModel: imageVM).padding(.bottom, 24)
            }
            
            if let textVM = viewModel.textVM {
                
                TextView(viewModel: textVM)
            }
        }
    }
}

extension CurrencyExchangeConfirmationView {

    struct TableView: View {
        
        @ObservedObject var viewModel: ViewModel.TableViewModel
        
        var body: some View {
            
            ZStack {
                
                Color.mainColorsGrayLightest
                    .cornerRadius(12)
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Сумма перевода")
                        Text("Комиссия")
                        Text("Сумма зачисления в валюте")
                    }
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        
                        Text(viewModel.sum)
                        Text(viewModel.commission)
                        Text(viewModel.sumCurrency)
                    }
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
                    
                }.padding(.horizontal, 20)
                
            }
            .frame(height: 124)
            .padding(.horizontal, 20)
        }
    }
    
    
    struct ImageView: View {
        
        @State var viewModel: ViewModel.ImageViewModel
        var body: some View {
            
            viewModel.image
                .resizable()
                .frame(width: 88, height: 88)
        }
    }
    
    
    struct TextView: View {
        
        @State var viewModel: ViewModel.TextViewModel
        var body: some View {
           
            VStack(spacing: 24) {
                
                Text(viewModel.text)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.value)
                    .font(.textH1SB24322())
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
}


//MARK: - Preview

struct CurrencyExchangeConfirmationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CurrencyExchangeConfirmationView(viewModel: .needConfirm)
                .previewLayout(.fixed(width: 375, height: 160))
            
            CurrencyExchangeConfirmationView(viewModel: .successImage)
                .previewLayout(.fixed(width: 375, height: 300))
            
            CurrencyExchangeConfirmationView(viewModel: .fullSuccess)
                .previewLayout(.fixed(width: 375, height: 400))

            CurrencyExchangeConfirmationView(viewModel: .error)
                .previewLayout(.fixed(width: 375, height: 400))
            
            CurrencyExchangeConfirmationView(viewModel: .waiting)
                .previewLayout(.fixed(width: 375, height: 400))
        }
    }
}

extension CurrencyExchangeConfirmationView.ViewModel {
    
    static var needConfirm = CurrencyExchangeConfirmationView
                                .ViewModel(state: .needConfirm,
                                           tableVM: .init(sum: "64,50",
                                                          commission: "0,00",
                                                          sumCurrency: "1 $"),
                                           imageVM: nil,
                                           textVM: nil)
    
    static var successImage = CurrencyExchangeConfirmationView
                                .ViewModel(state: .successImage,
                                           tableVM: .init(sum: "64,50",
                                                          commission: "0,00",
                                                          sumCurrency: "1 $"),
                                           imageVM: .init(image: Image("Done")),
                                           textVM: nil)
    
    
    static var fullSuccess = CurrencyExchangeConfirmationView
                                .ViewModel(state: .fullSuccess,
                                           tableVM: .init(sum: "64,50",
                                                          commission: "0,00",
                                                          sumCurrency: "1 $"),
                                           imageVM: .init(image: Image("Done")),
                                           textVM: .init(text: "Успешный перевод",
                                                         value: "64,50"))
    
    static var error = CurrencyExchangeConfirmationView
                                .ViewModel(state: .error,
                                           tableVM: .init(sum: "64,50",
                                                          commission: "0,00",
                                                          sumCurrency: "1 $"),
                                           imageVM: .init(image: Image("Denied")),
                                           textVM: .init(text: "Операция неуспешна!",
                                                         value: "64,50"))
    
    static var waiting = CurrencyExchangeConfirmationView
                                .ViewModel(state: .waiting,
                                           tableVM: .init(sum: "64,50",
                                                          commission: "0,00",
                                                          sumCurrency: "1 $"),
                                           imageVM: .init(image: Image("waiting")),
                                           textVM: .init(text: "Операция в обработке!",
                                                         value: "64,50"))
}


