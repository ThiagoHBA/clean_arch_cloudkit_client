//
//  SubtaskDAOTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 30/12/22.
//

import XCTest
import CloudKit
@testable import cloudkit_client

final class SubtaskDAOTest: XCTestCase {
    func test_fetchSubtask_whenSuccess_should_preserveRecordType() {
        let expectation = XCTestExpectation(description: "DatabaseCalled")
        let (sut, (database, _)) = makeSUT()
        let expectedItem = CKRecord.ID(recordName: "SubtaskItem")
        
        sut.fetchSubtask(id: expectedItem) { result in
            switch result {
                case .success(let record):
                    XCTAssertEqual(record.recordType, expectedItem.recordName)
                    expectation.fulfill()
                case .failure(_):
                    XCTFail("received item has different id from inputed item")
            }
        }
        
        successfullyCompleteQuery(database)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchSubtask_whenSuccess_shouldCallFetch_onlyOnce() {
        let (sut, (database, _)) = makeSUT()
        let expectedItem = CKRecord.ID(recordName: "SubtaskItem")
        sut.fetchSubtask(id: expectedItem) { _ in }
        successfullyCompleteQuery(database)
        XCTAssertEqual(database.fetchWithRecordIdCalled, 1)
    }
    
}

extension SubtaskDAOTest {
    func successfullyCompleteQuery(_ database: CloudKitDatabaseMock) {
        XCTAssertNoThrow(try database.completeFetchWithId(
            record: CKRecord(recordType: "SubtaskItem"),
            error: nil
        ))
    }
}

extension SubtaskDAOTest: Testing {
    typealias sutAndDoubles = (SubtaskDAO, (CloudKitDatabaseMock, CloudKitClient))
    func makeSUT() -> sutAndDoubles {
        let databaseMock = CloudKitDatabaseMock()
        let client = CloudKitClient(database: databaseMock)
        let sut = SubtaskDAO(client: client)

        return (sut, (databaseMock, client))
    }
}
