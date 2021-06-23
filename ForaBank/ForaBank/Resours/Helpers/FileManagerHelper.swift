//
//  FileManagerHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.06.2021.
//


import Foundation

struct FileManagerHandler {
    
    /// Получаем путь к директории хранения
    /// - Returns: Возвращает путь к директории
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /// Сохраняем файл
    /// - Parameters:
    ///   - filePath: Путь к файлу, возвращает, совпадает с именем запроса в модели. Например: playlistGet
    ///   - fileText: Сохраняемое содержимое файла. Например: /api/item
    /// Пример: Если надо сохранить /api/playlist в файл playlist.txt, то будет fileSave( playlist.txt, /api/playlist )
    public func fileSave (_ filePath: String, fileText: String) {
        
        if self.fileExist(filePath) {
            self.fileDelete(filePath)
        }
        let url = self.getDocumentsDirectory().appendingPathComponent(filePath)
        do {
            try fileText.write(to: url, atomically: true, encoding: .utf8)
//            print("FileText", try String(contentsOf: url) )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func fileRead (_ filePath: String) -> String {
        
        var input = ""
        let url = self.getDocumentsDirectory().appendingPathComponent(filePath)
        do {
            input = try String(contentsOf: url, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        return input
    }
    
    public func fileDelete (_ filePath: String) {
        let filemgr = FileManager.default
        guard self.fileExist(filePath) == true else { return }
        do {
            let url = self.getDocumentsDirectory().appendingPathComponent(filePath)
            try filemgr.removeItem(atPath: url.path)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    /// Проверка наличия файла по пути.
    /// - Parameter filePath: Путь к файлу
    /// - Returns: Если файл есть, то возвращает true
    
    func fileExist (_ filePath: String) -> Bool {
        let filemgr = FileManager.default
        let url = self.getDocumentsDirectory().appendingPathComponent(filePath)
        if filemgr.fileExists(atPath: url.path) {
            return true
        } else {
            return false
        }
    }
    
    public init() {}
}

