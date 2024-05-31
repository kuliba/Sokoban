//
//  Appearance+ext.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

extension Appearance {
    
    static let previewCard: Self = .init(background: .init(color: Color(red: 92/255, green: 161/255, blue: 164/255), image: nil), colors: .init(text: .white, checkBackground: .red))

    static let previewAccount: Self = .init(background: .init(color: Color(red: 230/255, green: 227/255, blue: 228/255), image: nil), colors: .init(text: Color(red: 0.11, green: 0.11, blue: 0.11), checkBackground: .red))

    static let previewLoan: Self = .init(background: .init(color: Color(red: 187/255, green: 190/255, blue: 200/255), image: nil), colors: .init(text: .white, checkBackground: .red))
    
    static let previewDeposit: Self = .init(background: .init(color: Color(red: 221/255, green: 190/255, blue: 170/255), image: nil), colors: .init(text: .white, checkBackground: .red))
}
