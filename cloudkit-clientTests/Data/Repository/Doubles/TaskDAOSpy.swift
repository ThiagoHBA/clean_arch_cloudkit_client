//
//  TaskDAOMock.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 01/01/23.
//

import Foundation
import CloudKit
@testable import cloudkit_client

class TaskDAOSpy: TaskDAOProtocol {
    var fetchAllData: (() -> (Result<[CKRecord], Error>))?
    private(set) var fetchAllCalled = 0
    
    func fetchAll(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        fetchAllCalled += 1
        completion(fetchAllData!())
    }
}


