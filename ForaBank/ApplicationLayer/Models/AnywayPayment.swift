import Foundation

// MARK: - AnywayPayment
class AnywayPaymentModel: Codable {
    var additional: [Additional]?

    init(additional: [Additional]?) {
        self.additional = additional
    }
    var dictionaryRepresentation: [String: Any] {
        return [
            "additional" : [],
        ]
    }
}

// MARK: - Additional
class Additional: Codable {
    var fieldid: Int?
    var fieldname, fieldvalue: String?

    init(fieldid: Int?, fieldname: String?, fieldvalue: String?) {
        self.fieldid = fieldid
        self.fieldname = fieldname
        self.fieldvalue = fieldvalue
    }
}



// MARK: - MPMakePayment
class MPMakePayment: Codable {
    let data: MPData?
    let errorMessage, result: String?

    init(data: MPData?, errorMessage: String?, result: String?) {
        self.data = data
        self.errorMessage = errorMessage
        self.result = result
    }
}

// MARK: - MPData
class MPData: Codable {
    let amount, commission: Int?
    let error, errorMessage: String?
    let finalStep: Int?
    let id: String?
    let listInputs: [MPListInput]?

    init(amount: Int?, commission: Int?, error: String?, errorMessage: String?, finalStep: Int?, id: String?, listInputs: [MPListInput]?) {
        self.amount = amount
        self.commission = commission
        self.error = error
        self.errorMessage = errorMessage
        self.finalStep = finalStep
        self.id = id
        self.listInputs = listInputs
    }
}

// MARK: - MPListInput
class MPListInput: Codable {
    let content: [MPContent]?
    let dataType, hint, id, mask: String?
    let max, min: Int?
    let name, note, onChange: String?
    let order, paramGroup: Int?
    let print, readOnly: Bool?
    let regExp: String?
    let req: Bool?
    let rightNum: Int?
    let sum, template: Bool?
    let type: String?
    let visible: Bool?

    init(content: [MPContent]?, dataType: String?, hint: String?, id: String?, mask: String?, max: Int?, min: Int?, name: String?, note: String?, onChange: String?, order: Int?, paramGroup: Int?, print: Bool?, readOnly: Bool?, regExp: String?, req: Bool?, rightNum: Int?, sum: Bool?, template: Bool?, type: String?, visible: Bool?) {
        self.content = content
        self.dataType = dataType
        self.hint = hint
        self.id = id
        self.mask = mask
        self.max = max
        self.min = min
        self.name = name
        self.note = note
        self.onChange = onChange
        self.order = order
        self.paramGroup = paramGroup
        self.print = print
        self.readOnly = readOnly
        self.regExp = regExp
        self.req = req
        self.rightNum = rightNum
        self.sum = sum
        self.template = template
        self.type = type
        self.visible = visible
    }
}

// MARK: - MPContent
class MPContent: Codable {

    init() {
    }
}
