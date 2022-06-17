//
//  BankData+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 08.06.2022.
//

import Foundation

extension BankData {
    
    func getBanksList() -> BanksList {
    
        return .init(memberID: memberId, memberName: memberName, memberNameRus: memberNameRus, md5Hash: md5hash, svgImage: svgImage.description, paymentSystemCodeList: paymentSystemCodeList)
    }
}
