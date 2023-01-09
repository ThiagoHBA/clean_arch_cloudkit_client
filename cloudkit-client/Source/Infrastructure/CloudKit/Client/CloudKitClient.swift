//
//  CloudKitService.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 24/12/22.
//

import Foundation
import CloudKit

class CloudKitClient: CloudKitClientProtocol {
    internal var database: CKDatabaseProtocol
    
    init(database: CKDatabaseProtocol = CKContainer(identifier: Constant.containerIdentifier).privateCloudDatabase) {
        self.database = database
    }
    
    func fetchData(query: CKQuery, completion: @escaping (Result<[(CKRecord.ID, Result<CKRecord, Error>)], Error>) -> Void) {
        database.fetch(
            withQuery: query,
            inZoneWith: nil,
            desiredKeys: nil,
            resultsLimit: CKQueryOperation.maximumResults
        ) { result in
            switch result {
                case .success(let (matchResults, _ )):
                    completion(.success(matchResults))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func fetchPerId(_ id: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        database.fetch(withRecordID: id) { record, error in
            if let error = error {
                completion(.failure(error))
            }
            if let record = record {
                completion(.success(record))
            }
        }
    }
}

extension CKDatabase: CKDatabaseProtocol { }