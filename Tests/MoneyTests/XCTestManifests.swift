import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CurrencyTests.allTests),
        testCase(MoneyTests.allTests),
        testCase(DecodingTests.allTests),
        testCase(EncodingTests.allTests),
    ]
}
#endif
