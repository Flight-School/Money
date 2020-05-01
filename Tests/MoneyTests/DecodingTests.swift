import XCTest
import Foundation
import Money

final class DecodingTests: XCTestCase {
    let decoder = JSONDecoder()

    func testDecodeKeyedContainerWithNumberAmount() throws {
        let json = #"""
            {
                "amount": 27.31,
                "currencyCode": "USD"
            }
        """#.data(using: .utf8)!

        let actual = try decoder.decode(Money<USD>.self, from: json)
        let expected = Money<USD>(Decimal(string: "27.31")!)

        XCTAssertEqual(actual, expected)
    }

    func testDecodeKeyedContainerWithStringAmount() throws {
        let json = #"""
             {
                 "amount": "27.31",
                 "currencyCode": "USD"
             }
         """#.data(using: .utf8)!

        let actual = try decoder.decode(Money<USD>.self, from: json)
        let expected = Money<USD>(Decimal(string: "27.31")!)

        XCTAssertEqual(actual, expected)
    }

    func testDecodeNumberAmount() throws {
        let json = #"""
            [
                27.31
            ]
        """#.data(using: .utf8)!

        let actual = try decoder.decode([Money<USD>].self, from: json)
        let expected = [Money<USD>(Decimal(string: "27.31")!)]

        XCTAssertEqual(actual, expected)
    }

    func testDecodeNegativeNumberAmount() throws {
        let json = #"""
              [
                  -27.31
              ]
          """#.data(using: .utf8)!

        let actual = try decoder.decode([Money<USD>].self, from: json)
        let expected = [Money<USD>(Decimal(string: "-27.31")!)]

        XCTAssertEqual(actual, expected)
    }

    func testDecodeIntegerNumberAmount() throws {
        let json = #"""
              [
                  27
              ]
          """#.data(using: .utf8)!

        let actual = try decoder.decode([Money<USD>].self, from: json)
        let expected = [Money<USD>(Decimal(string: "27")!)]

        XCTAssertEqual(actual, expected)
    }

    func testDecodeZeroNumberAmount() throws {
        let json = #"""
              [
                  0
              ]
          """#.data(using: .utf8)!

        let actual = try decoder.decode([Money<USD>].self, from: json)
        let expected = [Money<USD>(Decimal(string: "0")!)]

        XCTAssertEqual(actual, expected)
    }

    func testDecodeExponentNumberAmount() throws {
        let json = #"""
              [
                  2.731e1
              ]
          """#.data(using: .utf8)!

        let actual = try decoder.decode([Money<USD>].self, from: json)
        let expected = [Money<USD>(Decimal(string: "27.31")!)]

        XCTAssertEqual(actual, expected)
    }

    func testDecodeKeyedContainerWithMismatchedCurrency() throws {
        let json = #"""
            {
                "amount": 27.31,
                "currencyCode": "EUR"
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    func testDecodeKeyedContainerWithMissingCurrency() throws {
        let json = #"""
            {
                "amount": 27.31,
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    func testDecodeKeyedContainerWithMissingAmount() throws {
        let json = #"""
            {
                "currencyCode": "USD"
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    func testDecodeEmptyKeyedContainer() throws {
        let json = #"""
            {
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    static var allTests = [
        ("testDecodeKeyedContainerWithNumberAmount", testDecodeKeyedContainerWithNumberAmount),
        ("testDecodeKeyedContainerWithStringAmount", testDecodeKeyedContainerWithStringAmount),
        ("testDecodeNumberAmount", testDecodeNumberAmount),
        ("testDecodeNegativeNumberAmount", testDecodeNegativeNumberAmount),
        ("testDecodeIntegerNumberAmount", testDecodeIntegerNumberAmount),
        ("testDecodeZeroNumberAmount", testDecodeZeroNumberAmount),
        ("testDecodeExponentNumberAmount", testDecodeExponentNumberAmount),
        ("testDecodeKeyedContainerWithMismatchedCurrency", testDecodeKeyedContainerWithMismatchedCurrency),
        ("testDecodeKeyedContainerWithMissingCurrency", testDecodeKeyedContainerWithMissingCurrency),
        ("testDecodeKeyedContainerWithMissingAmount", testDecodeKeyedContainerWithMissingAmount),
        ("testDecodeEmptyKeyedContainer", testDecodeEmptyKeyedContainer),
    ]
}
