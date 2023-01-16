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
    var fetchAllData: ((Result<[CKRecord], Error>) -> Void)?
    var createData: ((Result<CKRecord, Error>) -> Void)?
    var findData: ((CKRecord?) -> Void)?
    
    // MARK: - Protocol Functions
    func fetchAll(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        fetchAllCalled += 1
        fetchAllData = completion
    }
    
    func create(_ task: Task, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        createCalled += 1
        createData = completion
    }

    func find(_ task: Task, completion: @escaping (CKRecord?) -> Void) {
        findCalled += 1
        findData = completion
    } 
}


