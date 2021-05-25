//
//  FirestoreService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

import FirebaseFirestore
import Firebase

extension Optional {
  var isNone: Bool {
    return self == nil
  }
  
  var isSome: Bool {
    return self != nil
  }
}

public enum FirestoreCollectionReference: String {
  case users = "Users"
  case conversations = "Conversations"
  case messages = "Messages"
}

public enum FirestoreResponse {
  case success
  case failure
}


class FirestoreService {
  
  private var listener: ListenerRegistration?
  
  func configure() {
    FirebaseApp.configure()
  }
  
  func objects<T>(_ object: T.Type, reference: Reference, parameter: DataQuery? = nil, completion: @escaping CompletionObject<[T]>) where T: FireCodable {
    guard let parameter = parameter else {
      reference.reference().getDocuments { (snapshot, error) in
        var results = [T]()
        snapshot?.documents.forEach({ (document) in
          if let objectData = document.data().data, let object = try? JSONDecoder().decode(T.self, from: objectData) {
            results.append(object)
          }
        })
        completion(results)
      }
      return
    }
    let queryReference: Query
    switch parameter.mode {
    case .equal:
      queryReference = reference.reference().whereField(parameter.key, isEqualTo: parameter.value)
    case .lessThan:
      queryReference = reference.reference().whereField(parameter.key, isLessThan: parameter.value)
    case .moreThan:
      queryReference = reference.reference().whereField(parameter.key, isGreaterThan: parameter.value)
    case .contains:
      queryReference = reference.reference().whereField(parameter.key, arrayContains: parameter.value)
    }
    queryReference.getDocuments { (snapshot, error) in
      var results = [T]()
      snapshot?.documents.forEach({ (document) in
        if let objectData = document.data().data, let object = try? JSONDecoder().decode(T.self, from: objectData) {
          results.append(object)
        }
      })
      completion(results)
    }
  }
  
  func update<T>(_ object: T, reference: Reference, completion: @escaping CompletionObject<FirestoreResponse>) where T: FireCodable {
    guard let data = object.values else { completion(.failure); return }
    reference.reference().document(object.id).setData(data, merge: true) { (error) in
      guard let _ = error else { completion(.success); return }
      completion(.failure)
    }
  }
  
  func delete<T>(_ objects: T.Type, reference: Reference, parameter: DataQuery, completion: @escaping CompletionObject<FirestoreResponse>) where T: FireCodable {
    let queryReference: Query
    switch parameter.mode {
    case .equal:
      queryReference = reference.reference().whereField(parameter.key, isEqualTo: parameter.value)
    case .lessThan:
      queryReference = reference.reference().whereField(parameter.key, isLessThan: parameter.value)
    case .moreThan:
      queryReference = reference.reference().whereField(parameter.key, isGreaterThan: parameter.value)
    case .contains:
      queryReference = reference.reference().whereField(parameter.key, arrayContains: parameter.value)
    }
    queryReference.getDocuments { (snap, error) in
      guard error.isNone else { completion(.failure); return }
      let batch = reference.reference().firestore.batch()
      snap?.documents.forEach({ (document) in
        batch.deleteDocument(document.reference)
      })
      batch.commit(completion: { (err) in
        guard err == nil else { completion(.failure); return }
        completion(.success)
      })
    }
  }
  
  func objectWithListener<T>(_ object: T.Type, parameter: DataQuery? = nil, reference: Reference, completion: @escaping CompletionObject<[T]>) where T: FireCodable {
    guard let parameter = parameter else {
      listener = reference.reference().addSnapshotListener({ (snapshot, _) in
        var objects = [T]()
        snapshot?.documents.forEach({ (document) in
          if let objectData = document.data().data, let object = try? JSONDecoder().decode(T.self, from: objectData) {
            objects.append(object)
          }
        })
        completion(objects)
      })
      return
    }
    let queryReference: Query
    switch parameter.mode {
    case .equal:
      queryReference = reference.reference().whereField(parameter.key, isEqualTo: parameter.value)
    case .lessThan:
      queryReference = reference.reference().whereField(parameter.key, isLessThan: parameter.value)
    case .moreThan:
      queryReference = reference.reference().whereField(parameter.key, isGreaterThan: parameter.value)
    case .contains:
      queryReference = reference.reference().whereField(parameter.key, arrayContains: parameter.value)
    }
    listener = queryReference.addSnapshotListener({ (snapshot, _) in
      var objects = [T]()
      snapshot?.documents.forEach({ (document) in
        if let objectData = document.data().data, let object = try? JSONDecoder().decode(T.self, from: objectData) {
          objects.append(object)
        }
      })
      completion(objects)
    })
  }
  
  func stopObservers() {
    listener?.remove()
  }
  
  deinit {
    listener?.remove()
  }
}


extension FirestoreService {
  
  struct DataQuery {
    
    let key: String
    let value: Any
    let mode: Mode
    
    enum Mode {
      case equal
      case lessThan
      case moreThan
      case contains
    }
  }
  
  struct Reference {
    
    private let locations: [FirestoreCollectionReference]
    private let documentID: String
    
    init(location: FirestoreCollectionReference) {
      self.locations = [location]
      self.documentID = ""
    }
    
    init(first: FirestoreCollectionReference, second: FirestoreCollectionReference, id: String) {
      self.locations = [first, second]
      self.documentID = id
    }
    
    func reference() -> CollectionReference {
      let ref = Firestore.firestore()
      guard locations.count == 2 else {
        return ref.collection(locations.first!.rawValue)
      }
      return ref.collection(locations.first!.rawValue).document(documentID).collection(locations.last!.rawValue)
    }
  }
}



extension Dictionary {
  
  var data: Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
  }
}

extension Encodable {
  var values: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
