//
//  SubtaskDAOMock.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 01/01/23.
//

import Foundation
import CloudKit
@testable import cloudkit_client

class SubtaskDAOMock: SubtaskDAOProtocol {
    var fetchSubtaskData: (() -> (Result<CKRecord, Error>))?
    private(set) var fetchSubtaskCalled = 0
    
    func fetchSubtask(id: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        fetchSubtaskCalled += 1
        completion(fetchSubtaskData!())
    }
}
