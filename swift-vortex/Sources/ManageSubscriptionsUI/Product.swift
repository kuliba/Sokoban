//
//  Product.swift
//  
//
//  Created by Дмитрий Савушкин on 20.07.2023.
//

public protocol Product: Identifiable {
    
    var subscriptions: [SubscriptionViewModel] { get set }
}
