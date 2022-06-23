//
//  FastPaymentContractFullInfoType+Legacy.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 21.06.2022.
//

extension FastPaymentContractFullInfoType {
    
    func getFastPaymentContractFindListDatum() -> FastPaymentContractFindListDatum {
       
        .init(fastPaymentContractAccountAttributeList:
                
                fastPaymentContractAccountAttributeList?.map {
                    FastPaymentContractAccountAttributeList
                        .init(accountID: $0.accountID,
                              flagPossibAddAccount: $0.flagPossibAddAccount?.rawValue,
                              maxAddAccount: $0.maxAddAccount != nil ? Int($0.maxAddAccount!) : nil,
                              minAddAccount: $0.minAddAccount != nil ? Int($0.minAddAccount!) : nil,
                              accountNumber: $0.accountNumber)
                },
        
              fastPaymentContractAttributeList:
                
                fastPaymentContractAttributeList?.map {
                    FastPaymentContractAttributeList
                        .init(accountID: $0.accountID,
                              branchID: $0.branchID,
                              clientID: $0.clientID,
                              flagBankDefault: $0.flagBankDefault?.rawValue,
                              flagClientAgreementIn: $0.flagClientAgreementIn?.rawValue,
                              flagClientAgreementOut: $0.flagClientAgreementOut?.rawValue,
                              phoneNumber: $0.phoneNumber,
                              branchBIC: $0.branchBIC,
                              fpcontractID: $0.fpcontractID)
                },
        
              fastPaymentContractClAttributeList:
                
                fastPaymentContractClAttributeList?.map {
                    FastPaymentContractClAttributeList
                        .init(clientInfo: .init(clientID: $0.clientInfo?.clientID,
                                                inn: $0.clientInfo?.inn,
                                                name: $0.clientInfo?.name,
                                                nm: $0.clientInfo?.nm,
                                                clientSurName: $0.clientInfo?.clientSurName,
                                                clientPatronymicName: $0.clientInfo?.clientPatronymicName,
                                                clientName: $0.clientInfo?.clientName,
                                                docType: $0.clientInfo?.docType,
                                                regSeries: $0.clientInfo?.regSeries,
                                                regNumber: $0.clientInfo?.regNumber,
                                                address: $0.clientInfo?.address))
                }
        )
    }
   
}
