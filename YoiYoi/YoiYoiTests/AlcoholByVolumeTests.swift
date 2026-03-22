import Foundation
import Testing
@testable import YoiYoi

struct AlcoholByVolumeTests {
    @Test func fromPercentageTypical() {
        let abv = AlcoholByVolume.fromPercentage(5.0)
        #expect(abv.fraction == 0.05)
        #expect(abv.percentage == 5.0)
    }

    @Test func fromFractionTypical() {
        let abv = AlcoholByVolume.fromFraction(0.12)
        #expect(abv.percentage == 12.0)
    }

    @Test func percentageBoundaryZero() {
        let abv = AlcoholByVolume.fromPercentage(0)
        #expect(abv.fraction == 0)
        #expect(abv.percentage == 0)
    }

    @Test func percentageBoundaryHundred() {
        let abv = AlcoholByVolume.fromPercentage(100)
        #expect(abv.fraction == 1.0)
        #expect(abv.percentage == 100)
    }

    @Test func fractionBoundaryOne() {
        let abv = AlcoholByVolume.fromFraction(1.0)
        #expect(abv.fraction == 1.0)
    }

    @Test func codableRoundTrip() throws {
        let original = AlcoholByVolume.fromFraction(0.055)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AlcoholByVolume.self, from: data)
        #expect(decoded == original)
    }
}
