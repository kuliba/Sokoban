//
//  SPStorage.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 01.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

final class SPStorage: NSObject {
    
    static let shared = SPStorage()

    var currentLevelCollection: SPLevelCollection {
        get {
            let CurrentLevelCollection = SPLevelCollection.shared
            if CurrentLevelCollection.levels.count == 0 || CurrentLevelCollection.fileName != SPSettings.shared.CurrentLevelCollectionFileName {
                CurrentLevelCollection.Load(FileName: SPSettings.shared.CurrentLevelCollectionFileName
                )
            }
            return CurrentLevelCollection
        }
    }
    
    private override init() {
        super.init()
        if !isOriginalLevelExists() {
            saveOriginalLevel()
        }
    }
    
    func isOriginalLevelExists() -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("/Levels/Original.slc")?.path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath!)
    }
    
    func saveOriginalLevel() -> () {
        if let path = Bundle.main.path(forResource: "Original", ofType: "slc") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let url = NSURL(fileURLWithPath: path)
                
                // Проверяем наличие папки Levels. Если ее нет, то создаем
                let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                let logsPath = documentsPath.appendingPathComponent("Levels")
                do {
                    try FileManager.default.createDirectory(at: logsPath!, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    NSLog("Unable to create directory \(error.localizedDescription)")
                }
                
                let filePath = url.appendingPathComponent("/Levels/Original.slc")?.path
                do {
                    try data.write(toFile: filePath!, atomically: true, encoding: .utf8)
                } catch {
                    print(error.localizedDescription)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
