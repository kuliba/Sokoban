//
//  Operators+Preview.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import Foundation
import OperatorsListComponents

extension Array where Element == Operator {
    
    static func page(
        pageNumber: Int = 0,
        pageSize: Int = 20
    ) -> Self {
        
        ((pageNumber*pageSize)..<((pageNumber+1)*pageSize))
            .map { index in
                
                Operator(
                    id: "\(index)",
                    title: "Operator #\(index)",
                    subtitle: "ИНН 123456789",
                    image: nil
                )
            }
    }
}
