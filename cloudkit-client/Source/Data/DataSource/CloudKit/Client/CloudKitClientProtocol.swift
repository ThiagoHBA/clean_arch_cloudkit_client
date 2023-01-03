//
//  CloudKitClient.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 26/12/22.
//

import Foundation
import CloudKit

protocol CloudKitClientProtocol {
    var database: CKDatabaseProtocol { get set }
    
    func fetchData(query: CKQuery, completion: @escaping (Result<[CKRecord], Error>) -> Void)
    func fetchPerId(_ id: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void)
}
