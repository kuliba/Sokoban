//
//  NetworkPDFManagerExtension.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.06.2021.
//

import Foundation

extension NetworkPDFManager:  URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        // create destination URL with the original pdf name
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Documentdo {
//            try FileManager.default.copyItem(at: location, to: destinationURL)
//            self.pdfURL = destinationURL
//        } catch let error {
//            print("Copy Error: \(error.localizedDescription)")
//        }
    }
}
