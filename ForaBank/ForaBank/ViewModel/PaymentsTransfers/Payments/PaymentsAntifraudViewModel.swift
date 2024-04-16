//
//  PaymentsAntifraudViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.12.2022.
//

import Foundation
import SwiftUI
import Combine

class PaymentsAntifraudViewModel {
    
    let header: HeaderViewModel
    let main: MainViewModel
    let bottom: BottomViewModel
    
    init(header: PaymentsAntifraudViewModel.HeaderViewModel, main: PaymentsAntifraudViewModel.MainViewModel, bottom: PaymentsAntifraudViewModel.BottomViewModel) {
        
        self.header = header
        self.main = main
        self.bottom = bottom
    }
    
    convenience init(
        payeeName: String,
        phone: String,
        amount: String,
        cancelAction: @escaping () -> Void,
        timeOutAction: @escaping () -> Void,
        continueAction: @escaping () -> Void
    ) {
        
        let main: MainViewModel = .init(
            name: payeeName,
            phone: phone,
            amount: amount,
            timer: .init(delay: .init(120), completeAction: timeOutAction)
        )
        
        let bottom: BottomViewModel = .init(
            cancelButton: .init(title: "Отменить", style: .gray, action: cancelAction),
            continueButton: .init(title: "Продолжить", style: .gray, action: continueAction)
        )
        
        self.init(header: .init(), main: main, bottom: bottom)
    }
    
    convenience init(
        with antifraudData: Payments.AntifraudData,
        cancelAction: @escaping () -> Void,
        timeOutAction: @escaping () -> Void,
        continueAction: @escaping () -> Void
    ) {
        
        self.init(
            payeeName: antifraudData.payeeName,
            phone: antifraudData.phone,
            amount: antifraudData.amount,
            cancelAction: cancelAction,
            timeOutAction: timeOutAction,
            continueAction: continueAction
        )
    }
    
}

//MARK: Sub ViewModel's
extension PaymentsAntifraudViewModel {
    
    struct MainViewModel {
        
        let name: String
        let phone: String
        let amount: String
        let timer: TimerViewModel
    }
    
    struct HeaderViewModel {
        
        let icon: Image = .ic40Danger
        let title: String = "Подозрительные действия"
        let description: String = "Есть подозрения в попытке совершения мошеннических операций"
    }
    
    struct BottomViewModel {
        
        let cancelButton: ButtonSimpleView.ViewModel
        let continueButton: ButtonSimpleView.ViewModel
    }
}

//MARK: TimerViewModel
extension PaymentsAntifraudViewModel {
    
    class TimerViewModel: ObservableObject {
        
        let delay: TimeInterval
        @Published var value: String
        let completeAction: () -> Void
        
        private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        private let startTime = Date.timeIntervalSinceReferenceDate
        private var formatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            return formatter
        }()
        
        private var bindings = Set<AnyCancellable>()
        
        init(delay: TimeInterval, completeAction: @escaping () -> Void) {
            
            self.delay = delay
            self.value = ""
            self.completeAction = completeAction
            
            bind()
            value = formatter.string(from: delay) ?? "0 :\(delay)"
        }
        
        func bind() {
            
            timer
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] time in
                    
                    let delta = time.timeIntervalSinceReferenceDate - startTime
                    let remain = delay - delta
                    
                    if remain <= 1 { completeAction() }
                    
                    value = formatter.string(from: remain) ?? "0 :\(remain)"
                    
                }.store(in: &bindings)
        }
    }
}
