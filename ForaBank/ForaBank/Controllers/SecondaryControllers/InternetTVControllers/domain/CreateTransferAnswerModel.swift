import Foundation

struct CreateTransferAnswerModel: Codable, NetworkModelProtocol {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateTransferAnswerModel.self, from: data)
    }

    let statusCode: Int?
    let errorMessage: String?
    let data: CreateTransferAnswerData?

    init(statusCode: Int?, errorMessage: String?, data: CreateTransferAnswerData?) {
        self.statusCode = statusCode
        self.errorMessage = errorMessage
        self.data = data
    }
}

struct CreateTransferAnswerData: Codable {
    let needMake, needOTP: Bool?
    let needSum: Bool?
    let currencyAmount: String?
    let amount, creditAmount: Double?
    let currencyPayer, currencyPayee: String?
    let currencyRate: Double?
    let debitAmount, fee: Double?
    let payeeName, documentStatus: String?
    let paymentOperationDetailID: Int?
    let additionalList: [AdditionalList2]?
    let parameterListForNextStep: [ParameterListForNextStep2]?
    let finalStep: Bool?
    let infoMessage: String?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, needSum, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList, parameterListForNextStep, finalStep, infoMessage
    }

    init(needMake: Bool?, needOTP: Bool?, needSum: Bool?, amount: Double?, creditAmount: Double?, fee: Double?, currencyAmount: String?, currencyPayer: String?, currencyPayee: String?, currencyRate: Double?, debitAmount: Double?, payeeName: String?, paymentOperationDetailID: Int?, documentStatus: String?, additionalList: [AdditionalList2]?, parameterListForNextStep: [ParameterListForNextStep2]?, finalStep: Bool?, infoMessage: String?) {
        self.needMake = needMake
        self.needOTP = needOTP
        self.needSum = needSum
        self.amount = amount
        self.creditAmount = creditAmount
        self.fee = fee
        self.currencyAmount = currencyAmount
        self.currencyPayer = currencyPayer
        self.currencyPayee = currencyPayee
        self.currencyRate = currencyRate
        self.debitAmount = debitAmount
        self.payeeName = payeeName
        self.paymentOperationDetailID = paymentOperationDetailID
        self.documentStatus = documentStatus
        self.additionalList = additionalList
        self.parameterListForNextStep = parameterListForNextStep
        self.finalStep = finalStep
        self.infoMessage = infoMessage
    }
}

struct AdditionalList2: Codable {
    let fieldTitle, fieldName, fieldValue, svgImage: String?

    init(fieldTitle: String?, fieldName: String?, fieldValue: String?, svgImage: String?) {
        self.fieldTitle = fieldTitle
        self.fieldName = fieldName
        self.fieldValue = fieldValue
        self.svgImage = svgImage
    }
}

struct ParameterListForNextStep2: Codable {
    let id: String?
    let order: Int?
    let title, subTitle, viewType, dataType: String?
    let type: String?
    let mask: String?
    let regExp: String?
    let maxLength, minLength: Int?
    let rawLength: Int?
    let isRequired: Bool?
    let content: String?
    let readOnly: Bool?
    let svgImage: String?

    init(id: String?, order: Int?, title: String?, subTitle: String?, viewType: String?, dataType: String?, type: String?, mask: String?, regExp: String?, maxLength: Int?, minLength: Int?, rawLength: Int?, isRequired: Bool?, content: String?, readOnly: Bool?, svgImage: String?) {
        self.id = id
        self.order = order
        self.title = title
        self.subTitle = subTitle
        self.viewType = viewType
        self.dataType = dataType
        self.type = type
        self.mask = mask
        self.regExp = regExp
        self.maxLength = maxLength
        self.minLength = minLength
        self.rawLength = rawLength
        self.isRequired = isRequired
        self.content = content
        self.readOnly = readOnly
        self.svgImage = svgImage
        
    }
}

