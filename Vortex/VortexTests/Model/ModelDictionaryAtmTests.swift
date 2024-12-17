//
//  ModelDictionaryAtmTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 25.04.2022.
//

import XCTest
@testable import ForaBank

class ModelDictionaryAtmTests: XCTestCase {
    
    func testReduceAtm_Insert() throws {

        // given
        let source = [AtmData]()
        let update: [AtmData] = [.insertOne, .insertTwo]
        
        // when
        let result = Model.dictionaryAtmReduce(current: source, update: update)
        
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, AtmData.insertOne.id)
        XCTAssertEqual(result[1].id, AtmData.insertTwo.id)
    }

    func testReduceAtm_Update() throws {

        // given
        let source: [AtmData] = [.insertOne, .insertTwo]
        let update: [AtmData] = [.updateOne]
        
        // when
        let result = Model.dictionaryAtmReduce(current: source, update: update)
        
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, AtmData.updateOne.id)
        XCTAssertEqual(result[0].name, AtmData.updateOne.name)
        XCTAssertEqual(result[1].id, AtmData.insertTwo.id)
    }
    
    func testReduceAtm_Delete() throws {

        // given
        let source: [AtmData] = [.insertOne, .insertTwo]
        let update: [AtmData] = [.deleteTwo]
        
        // when
        let result = Model.dictionaryAtmReduce(current: source, update: update)
        
        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, AtmData.insertOne.id)
    }
    
    func testReduceAtm_Insert_Update_Delete() throws {

        // given
        let source = [AtmData]()
        let update: [AtmData] = [.insertOne, .insertTwo, .updateOne, .deleteTwo]
        
        // when
        let result = Model.dictionaryAtmReduce(current: source, update: update)
        
        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, AtmData.updateOne.id)
        XCTAssertEqual(result[0].name, AtmData.updateOne.name)
    }
}

extension AtmData {
    
    static let insertOne = AtmData(id: "0", name: "test0", type: 0, serviceIdList: [0, 1], metroStationList: [0, 1], cityId: 0, address: "", schedule: "", location: .init(latitude: 0, longitude: 0), email: "", phoneNumber: "", action: .insert)
    
    static let insertTwo = AtmData(id: "1", name: "test1", type: 0, serviceIdList: [0, 1], metroStationList: [0, 1], cityId: 0, address: "", schedule: "", location: .init(latitude: 0, longitude: 0), email: "", phoneNumber: "", action: .insert)
    
    static let updateOne = AtmData(id: "0", name: "test_updated", type: 0, serviceIdList: [0, 1], metroStationList: [0, 1], cityId: 0, address: "", schedule: "", location: .init(latitude: 0, longitude: 0), email: "", phoneNumber: "", action: .update)
    
    static let deleteTwo = AtmData(id: "1", name: "test1", type: 0, serviceIdList: [0, 1], metroStationList: [0, 1], cityId: 0, address: "", schedule: "", location: .init(latitude: 0, longitude: 0), email: "", phoneNumber: "", action: .delete)
}
