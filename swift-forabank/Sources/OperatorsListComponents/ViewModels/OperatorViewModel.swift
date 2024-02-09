//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 09.02.2024.
//

import Foundation

public struct OperatorViewModel {
    
    let icon: Data
    let title: String
    let description: String?
    let action: () -> Void
}
