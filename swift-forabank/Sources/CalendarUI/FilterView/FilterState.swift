//
//  FilterState.swift
//  
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation

public struct FilterState {
    
    let title: String
    
    var selectedPeriod = "Месяц"
    var selectedTransaction = ""
    var selectedServices: Set<String> = []
    
    let periods: [String]
    let transactions: [String]
    let services: [String]
    
    public init(
        title: String,
        selectedPeriod: String = "Месяц",
        selectedTransaction: String = "",
        selectedServices: Set<String>,
        periods: [String],
        transactions: [String],
        services: [String]
    ) {
        self.title = title
        self.selectedPeriod = selectedPeriod
        self.selectedTransaction = selectedTransaction
        self.selectedServices = selectedServices
        self.periods = periods
        self.transactions = transactions
        self.services = services
    }
}
