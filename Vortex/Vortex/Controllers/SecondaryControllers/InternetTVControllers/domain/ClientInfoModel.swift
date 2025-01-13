import Foundation

struct ClintInfoModel: Codable, NetworkModelProtocol {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ClintInfoModel.self, from: data)
    }

    let statusCode: Int?
    let errorMessage: String?
    let data: ClintInfoModelData?

    init(statusCode: Int?, errorMessage: String?, data: ClintInfoModelData?) {
        self.statusCode = statusCode
        self.errorMessage = errorMessage
        self.data = data
    }
}

struct ClintInfoModelData: Codable {
    let clientId: Int?
    let phone: String?
    let email: String?
    let INN: String?
    let address: String?
    let firstName: String?
    let lastName: String?
    let patronymic: String?
    let regNumber: String?
    let regSeries: String?

    init(clientId: Int?, phone: String?, email: String?, INN: String?, address: String?, firstName: String?, lastName: String?, patronymic: String?, regNumber: String?, regSeries: String?) {
        self.address = address
        self.firstName = firstName
        self.lastName = lastName
        self.patronymic = patronymic
        self.regNumber = regNumber
        self.regSeries = regSeries
        self.clientId = clientId
        self.phone = phone
        self.email = email
        self.INN = INN
    }
}
