//
//  CloudKitClientSpy.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 29/12/22.
//

import Foundation
import CloudKit
@testable import cloudkit_client

class CloudKitDatabaseSpy: CKDatabaseProtocol {
    private(set) var fetchWithQueryCalled = 0
    private(set) var fetchWithRecordIdCalled = 0
    private(set) var createRecordCalled = 0
    
    // MARK: - Completions
    private(set) var fetchWithQueryCompletion: (
    
        ((Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>)
         -> Void)
    )?
    private(set) var fetchWithIdCompletion: ((CKRecord?, Error?) -> Void)?
    private(set) var createRecordCompletion: ((CKRecord?, Error?) -> Void)?
    
    // MARK: - Protocol function
    
    func fetch(withQuery query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, desiredKeys: [CKRecord.FieldKey]?, resultsLimit: Int, completionHandler: @escaping (Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) -> Void) {
        fetchWithQueryCompletion = completionHandler
        fetchWithQueryCalled += 1
    }
    
    func fetch(withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        fetchWithIdCompletion = completionHandler
        fetchWithRecordIdCalled += 1
    }
    
    func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        createRecordCompletion = completionHandler
        createRecordCalled += 1
    }
    
    // MARK: - Functions to complete protocols
    
    func completeFetchWithQuery(result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?), any Error>) {
        assert(fetchWithQueryCompletion != nil)
        fetchWithQueryCompletion!(result)
    }
    
    func completeFetchWithId(record: CKRecord?, error: Error?) {
        assert(fetchWithIdCompletion != nil)
        fetchWithIdCompletion!(record, error)
    }
    
    func completeCreateRecordQuery(record: CKRecord?, error: Error?) {
        assert(createRecordCompletion != nil)
        createRecordCompletion!(record, error)
    }
    
}
