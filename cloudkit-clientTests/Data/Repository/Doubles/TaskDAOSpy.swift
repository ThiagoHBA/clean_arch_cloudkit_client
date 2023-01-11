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
    private(set) var fetchAllCalled = 0
    private(set) var createCalled = 0
    private(set) var findCalled = 0
    
    // MARK: - Completions
    var fetchAllData: (() -> (Result<[CKRecord], Error>))?
    var createData: (() -> (Result<CKRecord, Error>))?
    var findData: (() -> CKRecord?)?
    
    // MARK: - Protocol Functions
    func fetchAll(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        assert(fetchAllData != nil)
        fetchAllCalled += 1
        completion(fetchAllData!())
    }
    
    func create(_ task: Task, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        assert(createData != nil)
        createCalled += 1
        completion(createData!())
    }

    func find(_ task: Task, completion: @escaping (CKRecord?) -> Void) {
        assert(findData != nil)
        findCalled += 1
        completion(findData!())
    } 
}


