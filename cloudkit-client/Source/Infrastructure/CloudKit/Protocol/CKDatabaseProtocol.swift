//
//  CKDatabaseProtocol.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 30/12/22.
//

import Foundation
import CloudKit

protocol CKDatabaseProtocol {
    func fetch(withQuery query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, desiredKeys: [CKRecord.FieldKey]?, resultsLimit: Int, completionHandler: @escaping (Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) -> Void)
    func fetch(withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord?, Error?) -> Void)
    func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void)
}
