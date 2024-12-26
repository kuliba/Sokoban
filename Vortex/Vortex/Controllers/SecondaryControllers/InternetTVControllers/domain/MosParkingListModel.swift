import Foundation

struct MosParkingListModel: Codable, NetworkModelProtocol {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MosParkingListModel.self, from: data)
    }

    let statusCode: Int?
    let errorMessage: String?
    let data: MosParkingListData?

    init(statusCode: Int?, errorMessage: String?, data: MosParkingListData?) {
        self.statusCode = statusCode
        self.errorMessage = errorMessage
        self.data = data
    }
}

struct MosParkingListData: Codable {
    let mosParkingList: [MOSParkingList]?
    let serial: String?

    init(mosParkingList: [MOSParkingList]?, serial: String?) {
        self.mosParkingList = mosParkingList
        self.serial = serial
    }
}

struct MOSParkingList: Codable {
    let mosParkingListDefault: Bool?
    let groupName, md5Hash, svgImage, text: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case mosParkingListDefault = "default"
        case groupName
        case md5Hash = "md5hash"
        case svgImage, text, value
    }

    init(mosParkingListDefault: Bool?, groupName: String?, md5Hash: String?, svgImage: String?, text: String?, value: String?) {
        self.mosParkingListDefault = mosParkingListDefault
        self.groupName = groupName
        self.md5Hash = md5Hash
        self.svgImage = svgImage
        self.text = text
        self.value = value
    }
}
