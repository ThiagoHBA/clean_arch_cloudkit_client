//
//  CloudKitClientSpy.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 29/12/22.
//

import Foundation
import CloudKit
@testable import cloudkit_client

class CloudKitDatabaseMock: CKDatabaseProtocol {
    private(set) var fetchWithQueryCalled = 0
    private(set) var fetchWithRecordIdCalled = 0
    private(set) var fetchWithQueryCompletion: (
    
        ((Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>)
         -> Void)
    )?
    private(set) var fetchWithIdCompletion: ((CKRecord?, Error?) -> Void)?
    
    func fetch(withQuery query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, desiredKeys: [CKRecord.FieldKey]?, resultsLimit: Int, completionHandler: @escaping (Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) -> Void) {
        fetchWithQueryCompletion = completionHandler
        fetchWithQueryCalled += 1
    }
    
    func fetch(withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        fetchWithIdCompletion = completionHandler
        fetchWithRecordIdCalled += 1
    }
    
    func completeFetchWithQuery(result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?), any Error>) throws {
        fetchWithQueryCompletion!(result)
    }
    
    func completeFetchWithId(record: CKRecord?, error: Error?) throws {
        fetchWithIdCompletion!(record, error)
    }
    
}
