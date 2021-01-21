@testable import App
import RQTFoundation
import XCTVapor

final class AppTests: XCTestCase {
    func testCRUDforRequirementVersions() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        let requirementVersionModel = RequirementVersionImpl(id: nil, text: "This is an example requirement", source: nil, createdAt: nil)
        try app.test(.POST, "requirementVersions", beforeRequest: { req in
            try req.content.encode(requirementVersionModel)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let reqVersion = try res.content.decode(RequirementVersionImpl.self)
            XCTAssertNotNil(reqVersion.id)
            XCTAssertNotNil(reqVersion.createdAt)
            try app.test(.GET, "requirementVersions", afterResponse: { res in
                let resBody = try? res.content.decode([RequirementVersionImpl].self)
                XCTAssertTrue(resBody != nil)
                XCTAssertTrue(resBody!.contains(where: { $0.id == reqVersion.id! }))
                XCTAssertEqual(res.status, .ok)
                try app.test(.DELETE, "requirementVersions/" + reqVersion.id!, afterResponse: { res in
                    XCTAssertEqual(res.status, .ok)
                    try app.test(.GET, "requirementVersions", afterResponse: { res in
                        let resBody = try? res.content.decode([RequirementVersionImpl].self)
                        XCTAssertFalse(resBody!.contains(where: { $0.id == reqVersion.id! }))
                    })
                })
            })
        })
    }
    
    func testCRUDforRequirementTag() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        let requirementVersionModel = RequirementVersionImpl(id: nil, text: "This is an example requirement", source: nil, createdAt: nil)
        try app.test(.POST, "requirementVersions", beforeRequest: { req in
            try req.content.encode(requirementVersionModel)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let reqVersion = try res.content.decode(RequirementVersionImpl.self)
            XCTAssertNotNil(reqVersion.id)
            XCTAssertNotNil(reqVersion.createdAt)
            let requirementTagModel = RequirementTagImpl(id: nil, target: reqVersion.id!, span: nil, attribute: "Passive", value: nil, createdAt: nil)
            try app.test(.POST, "tags", beforeRequest: { req in
                try req.content.encode(requirementTagModel)
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                let reqTag = try res.content.decode(RequirementTagImpl.self)
                XCTAssertNotNil(reqTag.id)
                XCTAssertNotNil(reqTag.createdAt)
                try app.test(.DELETE, "tags/" + reqTag.id!, afterResponse: { res in
                    XCTAssertEqual(res.status, .ok)
                    try app.test(.GET, "tags", afterResponse: { res in
                        let resBody = try? res.content.decode([RequirementTagImpl].self)
                        XCTAssertFalse(resBody!.contains(where: { $0.id == reqTag.id! }))
                    })
                })
            })
        })
    }
}
