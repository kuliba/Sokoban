import Foundation

// MARK: - BLBankList
class BLBankList: Codable {
    var data: [BLDatum]?
    var errorMessage, result: String?

    init(data: [BLDatum]?, errorMessage: String?, result: String?) {
        self.data = data
        self.errorMessage = errorMessage
        self.result = result
    }
}

// MARK: - BLDatum
class BLDatum: Codable {
    var id, memberID, memberName, memberNameRus: String?

    init(id: String?, memberID: String?, memberName: String?, memberNameRus: String?) {
        self.id = id
        self.memberID = memberID
        self.memberName = memberName
        self.memberNameRus = memberNameRus
    }
}
