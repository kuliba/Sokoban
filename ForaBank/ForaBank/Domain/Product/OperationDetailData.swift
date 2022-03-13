//
//  OperationDetailData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

struct OperationDetailData: Codable, Equatable {

	let account: String?
	let accountTitle: String?
	let amount: Double
	let billDate: String?
	let billNumber: String?
	let claimId: String
	let comment: String?
	let countryName: String?
	let currencyAmount: String
	let dateForDetail: String
	let driverLicense: String?
	let externalTransferType: ExternalTransferType?
	let isForaBank: Bool?
	let isTrafficPoliceService: Bool
	let memberId: String?
	let operation: String?
	let payeeAccountId: Int?
	let payeeAccountNumber: String?
	let payeeAmount: Double?
	let payeeBankBIC: String?
	let payeeBankCorrAccount: String?
	let payeeBankName: String?
	let payeeCardId: Int?
	let payeeCardNumber: String?
	let payeeCurrency: String?
	let payeeFirstName: String?
	let payeeFullName: String?
	let payeeINN: String?
	let payeeKPP: String?
	let payeeMiddleName: String?
	let payeePhone: String?
	let payeeSurName: String?
	let payerAccountId: Int
	let payerAccountNumber: String
	let payerAddress: String
	let payerAmount: Double
	let payerCardId: Int?
	let payerCardNumber: String?
	let payerCurrency: String
	let payerDocument: String?
	let payerFee: Double
	let payerFirstName: String
	let payerFullName: String
	let payerINN: String
	let payerMiddleName: String?
	let payerPhone: String?
	let payerSurName: String
	let paymentOperationDetailId: Int
	let paymentTemplateId: Int?
	let period: String?
	let printFormType: PrintFormType
	let provider: String?
	let puref: String?
	let regCert: String?
	let requestDate: String
	let responseDate: String
	let returned: Bool?
	let transferDate: String
	let transferEnum: TransferEnum?
	let transferNumber: String?
	let transferReference: String?
	
	enum ExternalTransferType: String, Codable {

		case entity = "ENTITY"
		case individual = "INDIVIDUAL"
	}

	enum TransferEnum: String, Codable {

		case accountToAccount = "ACCOUNT_2_ACCOUNT"
		case accountToCard = "ACCOUNT_2_CARD"
		case accountToPhone = "ACCOUNT_2_PHONE"
		case bankDef = "BANK_DEF"
		case bestToPay = "BEST2PAY"
		case cardToAccount = "CARD_2_ACCOUNT"
		case cardToCard = "CARD_2_CARD"
		case cardToPhone = "CARD_2_PHONE"
		case changeOutgoing = "CHANGE_OUTGOING"
		case contactAddressing = "CONTACT_ADDRESSING"
		case contactAddressless = "CONTACT_ADDRESSLESS"
		case depositOpen = "DEPOSIT_OPEN"
		case direct = "DIRECT"
		case elecsnet = "ELECSNET"
		case external = "EXTERNAL"
		case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
		case `internal` = "INTERNAL"
		case internet = "INTERNET"
		case meToMeCredit = "ME2ME_CREDIT"
		case meToMeDebit = "ME2ME_DEBIT"
		case mobile = "MOBILE"
		case oth = "OTH"
		case returnOutgoing = "RETURN_OUTGOING"
		case sfp = "SFP"
		case transport = "TRANSPORT"
	}
}
