//
//  TaskDAOTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 29/12/22.
//

import XCTest
import CloudKit
@testable import cloudkit_client

final class TaskDAOTest: XCTestCase {
    
    func test_fetchAll_whenSuccess_should_preserveRecordType() {
        let expectation = XCTestExpectation(description: "Database called with success")
        let (sut, (database, _)) = makeSUT()
        let expectedItem = CKRecord(recordType: "TaskItem")
        
        sut.fetchAll { result in
            switch result {
                case .success(let receivedItens):
                receivedItens.forEach { record in
                    XCTAssertEqual(expectedItem.recordType, record.recordType)
                }
                case .failure(_):
                    XCTFail("Item received does not correspond to item expected")
            }
            expectation.fulfill()
        }
        
        successfullyCompleteQuery(database)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchAll_whenSuccess_should_callFetchOnlyOnce() {
        let (sut, (database, _)) = makeSUT()
        sut.fetchAll { _ in }
        successfullyCompleteQuery(database)
        XCTAssertEqual(database.fetchWithQueryCalled, 1)
    }
    
    func test_fetchAll_when_success_should_return_items_correctly() {
        let (sut, (database, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called with success")
        sut.fetchAll { result in
            switch result {
            case .success(let recordList):
                XCTAssertTrue(!recordList.isEmpty)
            case .failure(let error):
                XCTFail("Unexpected error raised: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        successfullyCompleteQuery(database)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchAll_when_error_should_complete_correctly() {
        let (sut, (database, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called with error")
        
        sut.fetchAll { result in
            switch result {
                case .success(_):
                    XCTFail("The test should raise error not success")
                case .failure(_):
                    break
                }
            expectation.fulfill()
        }
        
        withFailureCompleteQuery(database)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchAll_when_error_should_receive_a_ckerror() {
        let (sut, (database, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called with error")
        
        sut.fetchAll { result in
            switch result {
            case .success(_):
                XCTFail("The test should raise error not success")
            case .failure(let error):
                XCTAssertNotNil(error as? CKError)
            }
            expectation.fulfill()
        }
        
        withFailureCompleteQuery(database)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_create_should_call_create_on_dataSource() {
        let (sut, (databaseSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called correctly")
        let inputTask = Task(isOpen: true, name: "", subtasks: [])
        
        sut.create(inputTask) { result in
            switch result {
                case .success(_):
                    XCTAssertEqual(databaseSpy.createRecordCalled, 1)
                case .failure(let error):
                XCTFail("function \(#function) should not raise error, but: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        successfullyCompleteCreateQuery(
            databaseSpy,
            successRecord: CKRecord(recordType: "TaskItem")
        )
        wait(for: [expectation], timeout: 1)
    }
    
    func test_create_when_success_should_return_created_record() {
        let (sut, (databaseSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called sucessfully")
        let task = Task(isOpen: false, name: "", subtasks: [])
        let inputRecord = CKRecord(recordType: "TaskItem")
        inputRecord.setValuesForKeys([
            "name": "",
            "isOpen": false,
            "subtasks": []
        ])
        sut.create(task) { result in
            switch result {
                case .success(let record):
                    XCTAssertEqual(record, inputRecord)
                case .failure(let error):
                    XCTFail("function \(#function) should not raise error, but: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        successfullyCompleteCreateQuery(databaseSpy, successRecord: inputRecord)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_create_when_fail_should_return_ckError() {
        let (sut, (databaseSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called sucessfully")
        let task = Task(isOpen: false, name: "", subtasks: [])
        let inputRecord = CKRecord(recordType: "TaskItem")
        
        inputRecord.setValuesForKeys([
            "name": "",
            "isOpen": false,
            "subtasks": []
        ])
        sut.create(task) { result in
            switch result {
                case .success(let record):
                    XCTFail("function \(#function) should raise error, but return \(record)")
                case .failure(let error):
                    XCTAssertNotNil(error as? CKError)
            }
            expectation.fulfill()
        }
        withFailureCompleteCreateRecordQuery(databaseSpy)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_find_when_success_should_call_database_query() {
        let (sut, (databaseSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called successfully")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        sut.find(inputTask) { _ in expectation.fulfill() }
        
        successfullyCompleteQuery(databaseSpy)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(databaseSpy.fetchWithQueryCalled, 1)
    }
    
    func test_find_when_fail_should_return_nil() {
        let (sut, (databaseSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called successfully")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        sut.find(inputTask) { task in
            XCTAssertNil(task)
            expectation.fulfill()
        }
        withFailureCompleteQuery(databaseSpy)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_find_when_success_should_return_task() {
        let (sut, (databaseSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "Database called successfully")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        sut.find(inputTask) { task in
            XCTAssertNotNil(task)
            expectation.fulfill()
        }
        successfullyCompleteQuery(databaseSpy)
        wait(for: [expectation], timeout: 1)
    }
}

extension TaskDAOTest {
    func successfullyCompleteQuery(_ database: CloudKitDatabaseSpy) {
        database.completeFetchWithQuery(
            result: .success(
                (
                    [(CKRecord.ID(recordName: "TaskItem"), .success(CKRecord(recordType: "TaskItem")))]
                    , nil
                )
            )
        )
    }
    
    func withFailureCompleteQuery(_ database: CloudKitDatabaseSpy) {
       database.completeFetchWithQuery(
            result: .failure(CKError(CKError.Code(rawValue: 4)!))
        )
        
    }
    
    func successfullyCompleteCreateQuery(_ database: CloudKitDatabaseSpy, successRecord: CKRecord) {
        database.completeCreateRecordQuery(
            record: successRecord,
            error: nil
        )
    }
    
    func withFailureCompleteCreateRecordQuery(_ database: CloudKitDatabaseSpy) {
        database.completeCreateRecordQuery(
            record: nil,
            error: CKError(CKError.Code(rawValue: 4)!)
        )
    }
}

extension TaskDAOTest: Testing {
    typealias sutAndDoubles = (TaskDAO, (CloudKitDatabaseSpy, CloudKitClient))
    func makeSUT() -> sutAndDoubles {
        let databaseMock = CloudKitDatabaseSpy()
        let client = CloudKitClient(database: databaseMock)
        let sut = TaskDAO(client: client)

        return (sut, (databaseMock, client))
    }
}


