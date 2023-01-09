//
//  TaskMapperTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 08/01/23.
//

import XCTest
import CloudKit
@testable import cloudkit_client

final class TaskMapperTest: XCTestCase {
    func test_mapToDomain_when_CKRecord_has_no_subtask_error_should_be_nil() {
        let (sut, _) = makeSUT()
        let inputRecord = CKRecord(recordType: "TaskItem")
        let inputSubtaskList: [CKRecord.Reference] = [CKRecord.Reference]()
        
        inputRecord.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": inputSubtaskList
        ])
        
        sut.mapToDomain(inputRecord) { _, error in
            XCTAssertNil(error)
        }
    }
    
    func test_mapToDomain_when_CKRecord_has_no_subtask_task_should_not_be_nil() {
        let (sut, _) = makeSUT()
        let inputRecord = CKRecord(recordType: "TaskItem")
        let inputSubtaskList: [CKRecord.Reference] = [CKRecord.Reference]()
        
        inputRecord.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": inputSubtaskList
        ])
        
        sut.mapToDomain(inputRecord) { task, _ in
            XCTAssertNotNil(task)
        }
    }
    
    func test_mapToDomain_when_CKRecord_has_no_subtask_should_map_correctly() {
        let (sut, _) = makeSUT()
        let inputRecord = CKRecord(recordType: "TaskItem")
        
        inputRecord.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": []
        ])
        
        sut.mapToDomain(inputRecord) { task, error in
            XCTAssertEqual(task, Task(isOpen: true, name: "", subtasks: []))
        }
    }
    
    func test_mapToDomain_when_fetchSubtasksReference_return_error_error_should_not_be_nil() {
        let (sut, databaseSpy) = makeSUT()
        let inputRecord = CKRecord(recordType: "TaskItem")
        let expectation = XCTestExpectation(description: "database return error")
        let inputSubtaskList = [CKRecord.Reference(record: CKRecord(recordType: "SubtaskItem"), action: .none)]
        
        inputRecord.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": inputSubtaskList
        ])
        
        sut.mapToDomain(inputRecord) { _ , error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        withFailureCompleteQuery(databaseSpy)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_mapToDomain_when_fetchSubtasksReference_return_error_task_should_be_nil() {
        let (sut, databaseSpy) = makeSUT()
        let inputRecord = CKRecord(recordType: "TaskItem")
        let expectation = XCTestExpectation(description: "database return error")
        let inputSubtaskList = [CKRecord.Reference(record: CKRecord(recordType: "SubtaskItem"), action: .none)]
        
        inputRecord.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": inputSubtaskList
        ])
        
        sut.mapToDomain(inputRecord) { task, _ in
            XCTAssertNil(task)
            expectation.fulfill()
        }
        
        withFailureCompleteQuery(databaseSpy)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_mapToDomain_when_fetcSubtasksReference_correctly_return_subtask_should_not_be_nil() {
        let (sut, databaseSpy) = makeSUT()
        let expectation = XCTestExpectation(description: "database return data")
        let inputRecord = CKRecord(recordType: "TaskItem")
        let inputSubtaskList = [CKRecord.Reference(record: CKRecord(recordType: "SubtaskItem"), action: .none)]
        let inputSubtask = CKRecord(recordType: "SubtaskItem")
        
        inputRecord.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": inputSubtaskList
        ])
        
        inputSubtask.setValuesForKeys([
            "done": true,
            "name": "",
            "task": CKRecord.Reference(record: inputRecord, action: .none)
        ])
        
        sut.mapToDomain(inputRecord) { task, _ in
            XCTAssertNotNil(task)
            expectation.fulfill()
        }
        
        successfullyCompleteQuery(databaseSpy, successData: inputSubtask)
        wait(for: [expectation], timeout: 2)
    }
    
    func test_mapToDomain_when_fetcSubtasksReference_correctly_return_subtask_should_map() {
        let (sut, databaseSpy) = makeSUT()
        let expectation = XCTestExpectation(description: "database return data")
        let inputRecord = CKRecord(recordType: "TaskItem")
        let inputSubtaskList = [CKRecord.Reference(record: CKRecord(recordType: "SubtaskItem"), action: .none)]
        
        let inputSubtask = CKRecord(recordType: "SubtaskItem")
        let expectedSubtask = Subtask(done: true, name: "", task: Task(isOpen: true, name: "", subtasks: []))
        
        inputRecord.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": inputSubtaskList
        ])
        
        inputSubtask.setValuesForKeys([
            "done": true,
            "name": "",
            "task": CKRecord.Reference(record: inputRecord, action: .none)
        ])
        
        sut.mapToDomain(inputRecord) { task, _ in
            XCTAssertEqual(task?.subtasks.filter({
                $0 == expectedSubtask
            }).count, 1)
            expectation.fulfill()
        }
        
        successfullyCompleteQuery(databaseSpy, successData: inputSubtask)
        wait(for: [expectation], timeout: 2)
    }
    
}

extension TaskMapperTest {
    func successfullyCompleteQuery(_ database: CloudKitDatabaseSpy, successData: CKRecord) {
        XCTAssertNoThrow(
            try database.completeFetchWithId(
                record: successData,
                error: nil
            )
        )
    }
    
    func withFailureCompleteQuery(_ database: CloudKitDatabaseSpy) {
        XCTAssertNoThrow(
            try database.completeFetchWithId(
                record: nil,
                error: CKError(CKError.Code(rawValue: 4)!))
        )
    }
}

extension TaskMapperTest: Testing {

    typealias SutAndDoubles = (TaskMapper, CloudKitDatabaseSpy)
    
    func makeSUT() -> SutAndDoubles {
        let databaseSpy = CloudKitDatabaseSpy()
        let sut = TaskMapper(client: CloudKitClient(database: databaseSpy))
        
        return (sut, databaseSpy)
    }
    
}
