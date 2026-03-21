//
//  YoiYoiTests.swift
//  YoiYoiTests
//
//  Created by Nozomu Kitamura on 3/22/26.
//

import Testing
@testable import YoiYoi

struct YoiYoiTests {

    @Test func alcoholByVolumeFromPercentage() {
        let abv = AlcoholByVolume.fromPercentage(5.0)
        #expect(abv.fraction == 0.05)
        #expect(abv.percentage == 5.0)
    }

    @Test func alcoholByVolumeFromFraction() {
        let abv = AlcoholByVolume.fromFraction(0.12)
        #expect(abv.percentage == 12.0)
    }
}
