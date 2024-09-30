//
//  ResponseMapper+mapGetOperatorsListByParamOperatorOnlyTrueResponseTests.swift
//
//
//  Created by Igor Malyarov on 13.09.2024.
//

import OperatorsListBackendV0
import RemoteServices
import XCTest

final class ResponseMapper_mapGetOperatorsListByParamOperatorOnlyTrueResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = "invalid data".data(using: .utf8)!
        
        let result = Self.mapOK(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = Self.map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = Self.map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = Data()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = Self.map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCodeWithBadData() throws {
        
        let badData = Data(jsonStringWithBadData.utf8)
        let statusCode = 400
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = Self.map(badData, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: badData
        )))
    }
    
    func test_map_should_deliverEmptyListOnMissingType() throws {
        
        let json = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "e484a0fa6826200868cb821394efa1ef",
        "operatorList": [
            {
                "type": null,
                "atributeList": []
            }
        ]
    }
}
"""
        let validData = Data(json.utf8)
        let result = Self.mapOK(validData)
        
        assert(result, equals: .success(.init(
            list: [],
            serial: "e484a0fa6826200868cb821394efa1ef"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnOkHTTPURLResponseStatusCodeWithValidData() throws {
        
        let validData = Data(jsonStringWithEmpty.utf8)
        let result = Self.mapOK(validData)
        
        assert(result, equals: .failure(.invalid(statusCode: 200, data: validData)))
    }
    
    func test_map_housingAndCommunalService() throws {
        
        let data = Data(String.housingAndCommunalService.utf8)
        let result = try Self.mapOK(data).get()
        
        XCTAssertEqual(result.list.count, 43)
        XCTAssert(result.list.allSatisfy { $0.type == "housingAndCommunalService" })
    }
    
    func test_map_education() throws {
        
        let data = Data(String.education.utf8)
        let result = try Self.mapOK(data).get()
        
        XCTAssertEqual(result.list.count, 3)
        XCTAssert(result.list.allSatisfy { $0.type == "education" })
    }
    
    func test_fromFile() throws {
        
        let data = try data(from: "getOperatorsListByParam")
        let response = try Self.mapOK(data).get()
        
        XCTAssertNoDiff(response.serial, "e484a0fa6826200868cb821394efa1ef")
        XCTAssertNoDiff(response.list, [
            .init(
                id: "17651",
                inn: "3704561992",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ООО  ИЛЬИНСКОЕ ЖКХ",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "21121",
                inn: "4217039402",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ООО МЕТАЛЛЭНЕРГОФИНАНС",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "12604",
                inn: "1657251193",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ТОВАРИЩЕСТВО СОБСТВЕННИКОВ НЕДВИЖИМОСТИ ЧИСТОПОЛЬСКАЯ 61 А",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "16399",
                inn: "7725412685",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ООО СЕРВИССТРОЙЭКСПЛУАТАЦИЯ",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "5823",
                inn: "7729398632",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ТСЖ ОЛИМП",
                type: "housingAndCommunalService"
            )
        ])
    }
    
    // MARK: - Helpers
    
    private static let map = ResponseMapper.mapGetOperatorsListByParamOperatorOnlyTrueResponse
    
    private static let mapOK = { data in
        
        map(data, anyHTTPURLResponse())
    }
    
    private func data(
        from filename: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let filename = Bundle.module.url(forResource: filename, withExtension: "json")
        let url = try XCTUnwrap(filename, file: file, line: line)
        return try Data(contentsOf: url)
    }
}

private extension String {
    
    static let education = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "360240a1aab9190c4c6c97ae198af9da",
        "operatorList": [
            {
                "type": "education",
                "atributeList": [
                    {
                        "md5hash": "cff7f296ad5d9be752c9621618cecba8",
                        "juridicalName": "ООО БИЗНЕС КОМПЕТЕНЦИЯ",
                        "customerId": "iFora-c7550a47-e32a-48db-873d-7758cf91c17c",
                        "serviceList": [],
                        "inn": "7750005860"
                    },
                    {
                        "md5hash": "cff7f296ad5d9be752c9621618cecba8",
                        "juridicalName": "СПб ГБПОУ Техникум Автосервис (МЦПК)",
                        "customerId": "iFora-67432fa9-a783-47c6-9abf-2f05e9bfbf85",
                        "serviceList": [],
                        "inn": "7750005860"
                    },
                    {
                        "md5hash": "cff7f296ad5d9be752c9621618cecba8",
                        "juridicalName": "Образовательные учреждения г. Москвы",
                        "customerId": "iFora-7631177b-fe0f-434f-afff-b99034108f7b",
                        "serviceList": [],
                        "inn": "7750005860"
                    }
                ]
            }
        ]
    }
}
"""
    
    static let housingAndCommunalService = "{\"statusCode\":0,\"errorMessage\":null,\"data\":{\"serial\":\"6bb28d36079964e2bec38e147fb14ea4\",\"operatorList\":[{\"type\":\"housingAndCommunalService\",\"atributeList\":[{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО УК ТЭН-СЕРВИС\",\"customerId\":\"10\",\"serviceList\":[],\"inn\":\"6658479810\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\" Омская энергосбытовая компания (тестовая среда поставщика доступна до 15 по мск)\",\"customerId\":\"iFora-0175d3d5-87d0-42ca-90b7-e13a53356b3f\",\"serviceList\":[],\"inn\":\"7736520080\"},{\"md5hash\":\"68c67dc421fa5ab13d76f6215bd1228f\",\"juridicalName\":\"Региональный фонд кап. ремонта МКД ЯО\",\"customerId\":\"iFora-d7994535-adc6-44a1-978c-865e60a12247\",\"serviceList\":[],\"inn\":\"7604194785\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО УК ЛЕНИНСКАЯ\",\"customerId\":\"3\",\"serviceList\":[],\"inn\":\"5404005067\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"МособлЕИРЦ с комиссией\",\"customerId\":\"iFora-72dae6d4-7bc3-414b-85ce-fa4e495dd428\",\"serviceList\":[],\"inn\":\"5037008735\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"МособлЕИРЦ без комиссии\",\"customerId\":\"iFora-297cb139-22da-44c2-83c3-ec639b8b8f59\",\"serviceList\":[],\"inn\":\"5037008735\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"Мособлгаз\",\"customerId\":\"iFora-b0dec0f4-6840-4b13-a3df-77b573a0cb2a\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"aeacabf71618e6f66aac16ed3b1922f3\",\"juridicalName\":\"ПАО Калужская сбытовая компания\",\"customerId\":\"iFora-43d9f89b-9c43-4f0c-a9bd-6dc8c867e391\",\"serviceList\":[],\"inn\":\"4029030252\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО «ЕРКЦ»\",\"customerId\":\"iFora-d61b41be-77d1-439b-85b6-637afa7e5f3e\",\"serviceList\":[],\"inn\":\"5249089687\"},{\"md5hash\":\"774d83055fe6dba082a0909083e593c2\",\"juridicalName\":\"ЖКХ Москвы\",\"customerId\":\"iFora-9603d57f-caaf-4fca-b854-3ac0657bbb64\",\"serviceList\":[],\"inn\":\"7702070139\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО БАЙКАЛЬСКАЯ ЭНЕРГЕТИЧЕСКАЯ КОМПАНИЯ\",\"customerId\":\"4\",\"serviceList\":[],\"inn\":\"3808229774\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"НКО Расчетные решения\",\"customerId\":\"1\",\"serviceList\":[],\"inn\":\"7723689508\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ДЕПАРТАМЕНТ ФИНАНСОВ КОМИТЕТА ПО БЮДЖЕТНОЙ ПОЛИТИКЕ И ФИНАНСАМ АДМИНИСТРАЦИИ Г.ИРКУТСКА\",\"customerId\":\"5\",\"serviceList\":[],\"inn\":\"3808193119\"},{\"md5hash\":\"5d13d80777eff5763173f99b9c02514e\",\"juridicalName\":\"МосОблЕИРЦ\",\"customerId\":\"iFora-7115db78-11e7-4a16-8ab1-7dd963f5b401\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"80a3e9bb59baf007b18b9264d43fa95f\",\"juridicalName\":\"Фонд кап. ремонта(НО ФКР МКД СПБ)\",\"customerId\":\"iFora-a8f1f706-6688-4244-8e2e-78b0da8cb3c6\",\"serviceList\":[],\"inn\":\"7736520080\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО НПФ СОФТВИДЕО\",\"customerId\":\"9\",\"serviceList\":[],\"inn\":\"50290036844\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"УК Одуванчик\",\"customerId\":\"iFora-42ca59a2-59e0-49f5-ab6c-52e20ccef01a\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ПАО ТНС энерго Ярославль\",\"customerId\":\"iFora-d4dc22f7-09a3-483c-b3dd-6da4692176ab\",\"serviceList\":[],\"inn\":\"7606052264\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"УК Ромашка\",\"customerId\":\"iFora-465d6508-0272-4c09-824d-dcb583204817\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"НАО \\\"РКЦ\\\" A3\",\"customerId\":\"iFora-be1bba78-ef28-4963-af0a-b2a5bb92d823\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"8358411f7c047b33f9a92e8cb6a7394f\",\"juridicalName\":\"АО Управдом Кировского района\",\"customerId\":\"iFora-dc3b2c6b-447e-49b0-bd98-f80ff600e2e4\",\"serviceList\":[],\"inn\":\"7604119315\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО ГРИН ПАРК\",\"customerId\":\"2\",\"serviceList\":[],\"inn\":\"3662251322\"},{\"md5hash\":\"486bd9a64ec3ebd1706a2aa033b3c155\",\"juridicalName\":\"ПИК-Комфорт\",\"customerId\":\"iFora-ba6c3b58-5e15-49e9-975a-a47dabd5836a\",\"serviceList\":[],\"inn\":\"7701208190\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО Расчетно-информационный центр г.Калуга\",\"customerId\":\"iFora-a792bc02-a0ad-41a6-adf0-cb8d6194749a\",\"serviceList\":[],\"inn\":\"4027115126\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"Мосэнергосбыт (произвольная сумма)\",\"customerId\":\"iFora-90c682cd-31dd-4374-a9c6-c37abfc34d94\",\"serviceList\":[],\"inn\":\"7736520080\"},{\"md5hash\":\"9989f5897ddcb9cbf978b64e627b8cb6\",\"juridicalName\":\"ООО «Ватт-Электросбыт»\",\"customerId\":\"iFora-d5170eb7-f93a-4ff4-b360-6fc705869a28\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"МУП АГО АНГАРСКИЙ ВОДОКАНАЛ\",\"customerId\":\"6\",\"serviceList\":[],\"inn\":\"3801006828\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"УК Терминатор\",\"customerId\":\"iFora-5c7eff53-4997-484c-a8cc-35cd808f1159\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ЖКХ Москвы (ЕИРЦ Банк Москвы)\",\"customerId\":\"iFora-6099279b-b2e5-4416-b216-bdd24a78d16a\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"Энергетическая компания «Восток»\",\"customerId\":\"iFora-41104650-73b1-47ef-b92f-a7048274f09f\",\"serviceList\":[],\"inn\":\"7736520080\"},{\"md5hash\":\"62e4170b223efcf4a65470eb635fac94\",\"juridicalName\":\"Мосэнергосбыт\",\"customerId\":\"iFora-411e4bfb-1c3a-46fb-809d-7586ab3a5519\",\"serviceList\":[],\"inn\":\"7736520080\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ЕРЦ Управдом\",\"customerId\":\"iFora-426994da-2238-477f-afa4-471c26e2a83f\",\"serviceList\":[],\"inn\":\"7702070139\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"Адамант\",\"customerId\":\"iFora-e393d281-aede-49df-bcd4-8bd33c73c0c3\",\"serviceList\":[],\"inn\":\"5249089687\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО Тепловодоканал п.Воротынск\",\"customerId\":\"iFora-e4443c55-9a91-42dd-ae9f-de849c8712a3\",\"serviceList\":[],\"inn\":\"4001005224\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"АО \\\"Татэнергосбыт\\\"\",\"customerId\":\"iFora-b108a3b5-c1d7-4f7d-8986-1207f963d557\",\"serviceList\":[],\"inn\":\"\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"Газпром Оренбург\",\"customerId\":\"iFora-f1b6c90d-8e0c-4e67-a725-14d1a7a845d2\",\"serviceList\":[],\"inn\":\"7736520080\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ЕИРЦ РБ\",\"customerId\":\"iFora-503d8ae2-d597-4b15-a420-fa79974fa95d\",\"serviceList\":[],\"inn\":\"7736520080\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"УК ДОМОВОЙ\",\"customerId\":\"12\",\"serviceList\":[],\"inn\":\"3019029665\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО МОСКВА\",\"customerId\":\"8\",\"serviceList\":[],\"inn\":\"7104002407\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ГУП МОСКОВСКИЙ МЕТРОПОЛИТЕН\",\"customerId\":\"7\",\"serviceList\":[],\"inn\":\"7702038150\"},{\"md5hash\":\"bf28505aec86419cd2e16ac8f708e5ab\",\"juridicalName\":\"Управдом Ленинского района\",\"customerId\":\"iFora-89a9e0bb-cce7-41c6-b546-4db2eb0775d2\",\"serviceList\":[],\"inn\":\"7606066274\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"ООО ЮГО-ВОСТОК\",\"customerId\":\"11\",\"serviceList\":[],\"inn\":\"4816022704\"},{\"md5hash\":\"1efeda3c9130101d4d88113853b03bb5\",\"juridicalName\":\"«ЕИРЦ СПб (ранее ЕИРЦ Петроэлектросбыт)»\",\"customerId\":\"iFora-78952524-ad14-48af-9cec-7f9e0ec9076c\",\"serviceList\":[],\"inn\":\"7736520080\"}]}]}}"
}
