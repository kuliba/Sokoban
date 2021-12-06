//
//  RealmPlaygroundTests.swift
//  RealmPlaygroundTests
//
//  Created by Max Gribov on 03.12.2021.
//

import XCTest
@testable import ForaBank
import RealmSwift

class RealmPlaygroundTests: XCTestCase {
    
    override func setUpWithError() throws {

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDownWithError() throws {
       
        let realm = try Realm()
        try realm.write {

            realm.deleteAll()
        }
    }
    
    func testWrite_Read() throws {

        // given
        let item = Item()
        let id = UUID().uuidString
        item.id = id
        
        // when
        let realm = try Realm()
        try realm.write {
            
            realm.add(item)
        }
        
        // then
        let items = realm.objects(Item.self)
        
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].id, id)
    }
    
    func testChanges_Updates() throws {
        
        // given
        
        // updated
        let one = Item()
        one.id = UUID().uuidString
        one.value = 0
        
        // update
        let two = Item()
        two.id = one.id
        two.value = 1
        
        let stored = [one]
        let recieved = [two]
        
        // when
        let changes = stored.update(with: recieved)
        
        // then
        XCTAssertNotNil(changes)
        XCTAssertEqual(changes?.updates.count, 1)
        XCTAssertEqual(changes?.removals.count, 0)
        XCTAssertEqual(changes?.additions.count, 0)
        
        XCTAssertEqual(changes?.updates[0].id, two.id)
        XCTAssertEqual(changes?.updates[0].value, two.value)
    }
    
    func testChanges_Removals() throws {
        
        // given
        
        // remoded
        let one = Item()
        one.id = UUID().uuidString
        one.value = 0
        
        let stored = [one]
        let recieved = [Item]()
        
        // when
        let changes = stored.update(with: recieved)
        
        // then
        XCTAssertNotNil(changes)
        XCTAssertEqual(changes?.updates.count, 0)
        XCTAssertEqual(changes?.removals.count, 1)
        XCTAssertEqual(changes?.additions.count, 0)
        
        XCTAssertEqual(changes?.removals[0].id, one.id)
        XCTAssertEqual(changes?.removals[0].value, one.value)
    }
    
    func testChanges_Additions() throws {
        
        // given
        
        // not changed
        let one = Item()
        one.id = UUID().uuidString
        one.value = 0
        
        // added
        let two = Item()
        two.id = one.id
        two.value = 1
        
        let stored = [one]
        let recieved = [two]
        
        // when
        let changes = stored.update(with: recieved)
        
        // then
        XCTAssertNotNil(changes)
        XCTAssertEqual(changes?.updates.count, 1)
        XCTAssertEqual(changes?.removals.count, 0)
        XCTAssertEqual(changes?.additions.count, 0)
        
        XCTAssertEqual(changes?.updates[0].id, two.id)
        XCTAssertEqual(changes?.updates[0].value, two.value)
    }
    
    func testChanges_Complex() throws {
        
        // given
        
        // removed
        let one = Item()
        one.id = UUID().uuidString
        one.value = 0
        
        // updated
        let two = Item()
        two.id = UUID().uuidString
        two.value = 1
        
        // update
        let three = Item()
        three.id = two.id
        three.value = 2
        
        // added
        let four = Item()
        four.id = UUID().uuidString
        four.value = 3
        
        let stored = [one, two]
        let recieved = [three, four]
        
        // when
        let changes = stored.update(with: recieved)
        
        // then
        XCTAssertNotNil(changes)
        XCTAssertEqual(changes?.updates.count, 1)
        XCTAssertEqual(changes?.removals.count, 1)
        XCTAssertEqual(changes?.additions.count, 1)
        
        XCTAssertEqual(changes?.updates[0].id, three.id)
        XCTAssertEqual(changes?.updates[0].value, three.value)
        
        XCTAssertEqual(changes?.removals[0].id, one.id)
        XCTAssertEqual(changes?.removals[0].value, one.value)
        
        XCTAssertEqual(changes?.additions[0].id, four.id)
        XCTAssertEqual(changes?.additions[0].value, four.value)
    }
    

    func testChanges_Complex_Save_Load() throws {
        
        // given
        
        // removed
        let one = Item()
        one.id = "a"
        one.value = 0
        
        // updated
        let two = Item()
        two.id = "b"
        two.value = 1
        
        // update
        let three = Item()
        three.id = two.id
        three.value = 2
        
        // added
        let four = Item()
        four.id = "c"
        four.value = 3
        
        let realm = try Realm()
        try realm.write {
            
            realm.add([one, two])
        }
        
        let stored = realm.objects(Item.self).sorted(byKeyPath: "id", ascending: true).toArray(ofType: Item.self)
        let recieved = [three, four]
        let changes = stored.update(with: recieved)!
       
        try realm.write({
            
            realm.delete(changes.removals)
            realm.add(changes.updates, update: .modified)
            realm.add(changes.additions)
        })

        // when
        let updated = realm.objects(Item.self).sorted(byKeyPath: "id", ascending: true).toArray(ofType: Item.self)
        
        // then

        XCTAssertEqual(updated.count, 2)
        
        XCTAssertEqual(updated[0].id, two.id)
        XCTAssertEqual(updated[0].value, three.value)
        
        XCTAssertEqual(updated[1].id, four.id)
        XCTAssertEqual(updated[1].value, four.value)
    }
}
     

