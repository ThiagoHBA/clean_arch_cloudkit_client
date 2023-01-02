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
        let expectation = XCTestExpectation(description: "DatabaseCalled")
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
}

extension TaskDAOTest {
    func successfullyCompleteQuery(_ database: CloudKitDatabaseMock) {
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
}

extension TaskDAOTest: Testing {
    typealias sutAndDoubles = (TaskDAO, (CloudKitDatabaseMock, CloudKitClient))
    func makeSUT() -> sutAndDoubles {
        let databaseMock = CloudKitDatabaseMock()
        let client = CloudKitClient(database: databaseMock)
        let sut = TaskDAO(client: client)

        return (sut, (databaseMock, client))
    }
}


