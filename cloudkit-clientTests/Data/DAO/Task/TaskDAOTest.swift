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
                expectation.fulfill()
                case .failure(_):
                    XCTFail("Item received does not correspond to item expected")
            }
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
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Unexpected error raised: \(error.localizedDescription)")
            }
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
                expectation.fulfill()
            }
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
                expectation.fulfill()
            }
        }
        
        withFailureCompleteQuery(database)
        wait(for: [expectation], timeout: 1)
    }
}

extension TaskDAOTest {
    func successfullyCompleteQuery(_ database: CloudKitDatabaseSpy) {
        XCTAssertNoThrow(
            try database.completeFetchWithQuery(
                result: .success(
                    (
                        [(CKRecord.ID(recordName: "TaskItem"), .success(CKRecord(recordType: "TaskItem")))]
                        , nil
                    )
                )
            )
        )
    }
    
    func withFailureCompleteQuery(_ database: CloudKitDatabaseSpy) {
        XCTAssertNoThrow(
            try database.completeFetchWithQuery(
                result: .failure(CKError(CKError.Code(rawValue: 4)!))
            )
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


