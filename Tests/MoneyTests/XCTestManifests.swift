import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MoneyTests.allTests),
        testCase(DecodingTests.allTests),
        testCase(EncodingTests.allTests),
    ]
}
#endif
