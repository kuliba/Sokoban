//
//  FireStorageService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import FirebaseStorage


class FirestorageService {
  
  func update<T>(_ object: T, reference: FirestoreCollectionReference, completion: @escaping CompletionObject<FirestoreResponse>) where T: FireStorageCodable {
    guard let imageData = object.profilePic?.scale(to: CGSize(width: 350, height: 350))?.jpegData(compressionQuality: 0.3) else { completion(.success); return }
    let ref = Storage.storage().reference().child(reference.rawValue).child(object.id).child(object.id + ".jpg")
    let uploadMetadata = StorageMetadata()
    uploadMetadata.contentType = "image/jpg"
    ref.putData(imageData, metadata: uploadMetadata) { (_, error) in
      guard error.isNone else { completion(.failure); return }
      ref.downloadURL(completion: { (url, err) in
        if let downloadURL = url?.absoluteString {
          object.profilePic = nil
          object.profilePicLink = downloadURL
          completion(.success)
          return
        }
        completion(.failure)
      })
    }
  }
}

extension UIImage {
  
  func fixOrientation() -> UIImage {
    if (imageOrientation == .up) { return self }
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    draw(in: rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
  
  func scale(to newSize: CGSize) -> UIImage? {
    let horizontalRatio = newSize.width / size.width
    let verticalRatio = newSize.height / size.height
    let ratio = max(horizontalRatio, verticalRatio)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
