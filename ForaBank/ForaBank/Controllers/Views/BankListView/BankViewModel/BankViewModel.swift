//
//  BankViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 03.07.2021.
//

import UIKit
import SVGKit

struct BankViewModel {
    
    let bank: BanksList
    var bankName: String {
        return bank.memberNameRus ?? ""
    }
    var bankImage: UIImage {
        let imageString = bank.svgImage ?? ""
        return convertSVGStringToImage(imageString)
    }
    
    init(bank: BanksList) {
        self.bank = bank
    }
    
    func convertSVGStringToImage(_ string: String) -> UIImage {
        let stringImage = string.replacingOccurrences(of: "\\", with: "")
        let imageData = Data(stringImage.utf8)
        let imageSVG = SVGKImage(data: imageData)
        let image = imageSVG?.uiImage ?? UIImage()
        return image
    }
    
}
