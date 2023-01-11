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
    
    func createRecord(_ record: CKRecord, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        database.save(record) { record, error in
            if let error = error {
                completion(.failure(error))
            }
            if let entity = record {
                completion(.success(entity))
            }
        }
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
    
    func findRecord(query: CKQuery, completion: @escaping (CKRecord?) -> Void) {
        database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
            switch result {
                case .success(let (matchResults, _ )):
                    if !matchResults.isEmpty {
                        switch matchResults.first!.1 {
                            case .success(let record):
                                completion(record)
                            case .failure(_):
                                completion(nil)
                        }
                    }
                case .failure(_):
                    completion(nil)
            }
        }
    }
}

extension CKDatabase: CKDatabaseProtocol { }
