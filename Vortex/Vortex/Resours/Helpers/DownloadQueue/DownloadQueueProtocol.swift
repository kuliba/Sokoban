//
//  DownloadQueueProtocol.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation

protocol DownloadQueueProtocol {
    func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping (DownloadQueue.Result) -> Void)
}
