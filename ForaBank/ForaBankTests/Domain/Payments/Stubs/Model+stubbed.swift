//
//  Model+stubbed.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.02.2023.
//

@testable import ForaBank
import Foundation

#if MOCK
extension Model {
    
    static let happyPath: Model = {
        
        let localAgentDataStub: [String: Data] = [
            "Array<OperatorGroupData>": .operatorGroupData,
        ]
        
        let serverAgentDataStub: [String: DaDataPhoneData] = [
            "9039999999": .iFora4285,
            "9191619658": .iFora4286,
        ]
        
        let essenceStub: ServerAgentStub.EssenceStub = .preview
        
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = ServerAgentStub(
            stub: serverAgentDataStub,
            essenceStub: essenceStub
        )
        let localAgent = LocalAgentStub(stub: localAgentDataStub)
        
        return .stubbed(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent,
            localAgent: localAgent
        )
    }()
    
    static func stubbed(
        sessionAgent: SessionAgentProtocol? = nil,
        serverAgent: ServerAgentProtocol? = nil,
        localAgent: LocalAgentProtocol? = nil
    ) -> Model {
        
        .init(
            sessionAgent: sessionAgent ?? SessionAgentEmptyMock(),
            serverAgent: serverAgent ?? ServerAgentEmptyMock(),
            localAgent: localAgent ?? LocalAgentEmptyMock(),
            keychainAgent: KeychainAgentMock(),
            settingsAgent: SettingsAgentMock(),
            biometricAgent: BiometricAgentMock(),
            locationAgent: LocationAgentMock(),
            contactsAgent: ContactsAgentMock(),
            cameraAgent: CameraAgentMock(),
            imageGalleryAgent: ImageGalleryAgentMock(),
            networkMonitorAgent: NetworkMonitorAgentMock()
        )
    }
}
#endif

extension Data {
    
    static var operatorGroupData: Self {
        
        let operatorGroupData = (try? OperatorGroupData.fromBundle())!
        return try! JSONEncoder().encode(operatorGroupData)
    }
}

extension DaDataPhoneData {

    static let iFora4285: Self = .iFora(
        cityCode: 903,
        md5hash: "2a025e81e19ddc447cc93d27ad75ff84",
        number: "9999999",
        phone: "+7 903 999-99-99",
        provider: "ПАО \"Вымпел-Коммуникации\"",
        puref: "iFora||4285",
        region: "Новосибирская область",
        source: "9039999999",
        svgImage: "<svg width=\"40\" height=\"40\" viewBox=\"0 0 40 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n<path d=\"M0 20C0 8.95431 8.95431 0 20 0V0C31.0457 0 40 8.95431 40 20V20C40 31.0457 31.0457 40 20 40V40C8.95431 40 0 31.0457 0 20V20Z\" fill=\"#FDCC0F\"/>\n<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M15.7505 0.322829C13.4918 0.81687 10.9393 1.92423 8.8902 3.29914C6.99642 4.5701 4.46891 6.92892 5.32636 6.62469C5.5658 6.53999 9.78925 6.34762 14.7118 6.19748C21.427 5.99258 25.0401 5.98956 29.181 6.18542C32.2163 6.32906 34.7338 6.41237 34.7752 6.37083C34.8168 6.32906 34.044 5.61364 33.058 4.78057C29.1942 1.51628 24.9451 -0.0322118 19.942 0.000507642C18.4012 0.010718 16.515 0.155751 15.7505 0.322829ZM0.540592 15.1589C-0.0769564 16.7749 -0.19552 22.0421 0.34183 23.9997L0.532964 24.6958L11.0322 24.7724C16.8069 24.8146 25.6093 24.7763 30.5929 24.6875L39.6541 24.5257L39.8376 23.4506C40.1076 21.869 40.0274 17.7024 39.6973 16.1679L39.4105 14.8336H20.0377C3.63388 14.8336 0.645981 14.8835 0.540592 15.1589ZM5.00672 33.3509C5.00672 33.6747 7.15936 35.5921 8.70461 36.6447C10.4778 37.8525 11.9673 38.5747 14.2515 39.334C16.0669 39.9375 16.4965 39.9879 19.9138 39.9993C22.8888 40.009 23.9055 39.9252 25.114 39.5711C27.173 38.9678 29.6356 37.8184 31.2987 36.6844C32.8273 35.642 35.2349 33.4997 35.0521 33.3442C34.9885 33.2904 33.6365 33.3389 32.0476 33.4523C28.955 33.6733 7.31952 33.5196 5.87341 33.2667C5.34115 33.1734 5.00672 33.2061 5.00672 33.3509Z\" fill=\"#0C0C0C\"/>\n</svg>\n",
        timezone: "UTC+7"
    )
    
    static let iFora4286: Self = .iFora(
        cityCode: 919,
        md5hash: "576097d55947bf708c4f03e7f8134f26",
        number: "1619658",
        phone: "+7 919 161-96-58",
        provider: "ПАО \"Мобильные ТелеСистемы\"",
        puref: "iFora||4286",
        region: "Липецкая область",
        source: "9191619658",
        svgImage: "<svg width=\"40\" height=\"40\" viewBox=\"0 0 40 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n<path d=\"M0 20C0 8.95431 8.95431 0 20 0V0C31.0457 0 40 8.95431 40 20V20C40 31.0457 31.0457 40 20 40V40C8.95431 40 0 31.0457 0 20V20Z\" fill=\"#E30600\"/>\n<path d=\"M12 22.31C12 26.655 14.365 31 19.59 31C24.815 31 27.18 26.655 27.18 22.31C27.18 19.34 26.19 15.93 24.595 13.235C23.055 10.595 21.185 9 19.59 9C17.995 9 16.125 10.595 14.585 13.235C12.99 15.985 12 19.395 12 22.31Z\" fill=\"white\"/>\n</svg>\n",
        timezone: "UTC+3"
    )
    
    static func iFora(
        cityCode: Int,
        country: String = "Россия",
        countryCode: Int = 7,
        md5hash: String,
        number: String,
        phone: String,
        provider: String,
        puref: String,
        qc: Int = 0,
        qcConflict: Int = 0,
        region: String,
        source: String,
        svgImage: String,
        timezone: String,
        type: String = "Мобильный"
    ) -> Self {
        
        .init(
            city: nil,
            cityCode: "\(cityCode)",
            country: country,
            countryCode: "\(countryCode)",
            extension: nil,
            md5hash: md5hash,
            number: number,
            phone: phone,
            provider: provider,
            puref: puref,
            qc: qc,
            qcConflict: qc,
            region: region,
            source: source,
            svgImage: svgImage,
            timezone: timezone,
            type: type
        )
    }
}

extension OperatorGroupData {

    static func fromBundle() throws -> [Self] {

        typealias Response = ServerCommands.DictionaryController.GetAnywayOperatorsList.Response
        
        class Bundler: NSObject {}
        let response: Response = try Bundler.data(
            fromFilename: "GetAnywayOperatorGroupDataResponseServer"
        )
        
        return response.data?.operatorGroupList ?? []
    }
}

extension ServerAgentStub.EssenceStub {
    
    static let preview: Self  = [
        .iFora_4285_9rub:   .iFora_4285_9rub,
        .iFora_4285_10rub:  .iFora_4285_10rub,
        .iFora_4286:        .iFora_4286,
        .iFora_515A3_1rub:  .iFora_515A3_1rub,
        .iFora_515A3_10rub: .iFora_515A3_10rub,
    ]
}

extension ServerAgentStub.Essence {
    
    static let iFora_4285_9rub: Self    = .init("iFora_4285",  "9039999999",  9.0)
    static let iFora_4285_10rub: Self   = .init("iFora_4285",  "9039999999", 10.0)
    static let iFora_4286: Self         = .init("iFora_4286",  "9191619658",  1.0)
    static let iFora_515A3_1rub: Self   = .init("iFora_515A3", "9999679969",  1.0)
    static let iFora_515A3_10rub: Self  = .init("iFora_515A3", "9999679969", 10.0)
    
    private init(_ puref: String, _ phoneNumber: String, _ amount: Double) {
        
        self.init(puref: puref, phoneNumber: phoneNumber, amount: amount)
    }
}

extension ServerCommands.TransferController.CreateAnywayTransfer.Payload {
    
    typealias Request = ServerCommands.TransferController.CreateAnywayTransfer.Payload
    
    static let iFora_4285_9rub: Request = try! decode(from: "createAnywayTransfer_iFora_4285_9rub_request")
    
    static let iFora_4285_10rub: Request = try! decode(from: "createAnywayTransfer_iFora_4285_10rub_request")
    
    static let iFora_4286: Request = try! decode(from: "createAnywayTransfer_iFora_4286_request")
    
    static let iFora_515A3_1rub: Request = try! decode(from: "createAnywayTransfer_iFora_515A3_1rub_request")
    
    static let iFora_515A3_10rub: Request = try! decode(from: "createAnywayTransfer_iFora_515A3_10rub_request")
    
    // MARK: - Helpers
    
    private static func decode(from filename: String) throws -> Request {
        
        try filename.decode(Request.self, bundle: .init(for: ServerAgentStub.self))
    }
}

extension ServerCommands.TransferController.CreateAnywayTransfer.Response {
    
    typealias Response = ServerCommands.TransferController.CreateAnywayTransfer.Response
    
    static let iFora_4285_9rub: Self = try! decode(from: "createAnywayTransfer_iFora_4285_9rub_response")

    static let iFora_4285_10rub: Self = try! decode(from: "createAnywayTransfer_iFora_4285_10rub_response")

    static let iFora_4286: Self = try! decode(from: "createAnywayTransfer_iFora_4286_response")

    static let iFora_515A3_1rub: Self = try! decode(from: "createAnywayTransfer_iFora_515A3_1rub_response")

    static let iFora_515A3_10rub: Self = try! decode(from: "createAnywayTransfer_iFora_515A3_10rub_response")

    // MARK: - Helpers
    
    private static func decode(from filename: String) throws -> Response {
        
        try filename.decode(Response.self, bundle: .init(for: ServerAgentStub.self))
    }
}

extension String {
    
    func decode<T: Decodable>(_ type: T.Type, bundle: Bundle) throws -> T {
        
        guard let url = bundle.url(forResource: self, withExtension: "json")
        else {
            throw NSError(domain: "No resource at URL", code: 0)
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
}
