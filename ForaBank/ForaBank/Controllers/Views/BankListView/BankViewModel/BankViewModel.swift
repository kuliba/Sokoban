//
//  BankViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 03.07.2021.
//

import UIKit

struct BankViewModel {
    
    let bank: BanksList
    var bankName: String {
        return bank.memberNameRus ?? ""
    }
    var bankImage: UIImage {
        if bank.svgImage  == "seeall"{
            return UIImage(named: bank.svgImage ?? "") ?? UIImage()
        } else {
            let imageString = bank.svgImage?.convertSVGStringToImage() ?? UIImage()
            return imageString
        }
    }
    
    init(bank: BanksList) {
        self.bank = bank
    }
    
}
