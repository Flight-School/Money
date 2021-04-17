import XCTest
import Foundation
@testable import Money

final class CurrencyTests: XCTestCase {
    func testCurrencyByISO4217Code() {
        let usd = iso4217Currency(for: "USD")
        XCTAssert(usd == USD.self)
        XCTAssertEqual(usd?.code, "USD")
        XCTAssertEqual(usd?.name, "US Dollar")
        XCTAssertEqual(usd?.minorUnit, 2)

        let unk = iso4217Currency(for: "UNK")
        XCTAssertNil(unk)
    }

    static var allTests = [
        ("testCurrencyByISO4217Code", testCurrencyByISO4217Code),
    ]
}
