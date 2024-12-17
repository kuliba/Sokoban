//
//  BankFullInfoData+Legacy.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 22.06.2022.
//

extension BankFullInfoData {
    
    var fullBankInfoList: BankFullInfoList {
    
         .init(name: name,
               memberID: memberId,
               rusName: rusName,
               fullName: fullName,
               engName: engName,
               md5Hash: md5hash,
               svgImage: svgImage.description,
               bic: bic,
               fiasID: fiasId,
               address: address,
               latitude: latitude != nil ? String(latitude!) : nil,
               longitude: longitude != nil ? String(longitude!) : nil,
               swiftList: nil,
               inn: inn,
               kpp: kpp,
               registrationNumber: registrationNumber,
               registrationDate: registrationDate,
               bankType: bankType,
               bankTypeCode: bankTypeCode,
               bankServiceType: bankServiceType,
               bankServiceTypeCode: bankServiceTypeCode,
               accountList: accountList
                                .map { AccountList(account: $0.account,
                                                   regulationAccountType: $0.regulationAccountType,
                                                   ck: $0.ck,
                                                   dateIn: $0.dateIn,
                                                   dateOut: $0.dateOut,
                                                   status: $0.status,
                                                   cbrbic: $0.cbrbic)
                                },
               senderList: senderList,
               receiverList: receiverList)
    }
}
