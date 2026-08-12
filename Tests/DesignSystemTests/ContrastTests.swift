import Foundation
import Testing
@testable import DesignSystem

@Suite("コントラスト計算")
struct ContrastTests {

    @Test("白と黒のコントラスト比は21対1")
    func whiteAndBlackRatio() {
        #expect(RelativeLuminance.white.contrastRatio(against: .black) == 21)
    }

    @Test("既定brandAccentのライト値は白文字がAAを満たす")
    func brandAccentLightPrefersWhite() {
        let luminance = Self.luminanceFromSRGB(red: 37, green: 102, blue: 229)

        #expect(luminance.contrastRatio(against: .white) >= 4.5)
        #expect(luminance.contrastRatio(against: .white) > luminance.contrastRatio(against: .black))
    }

    @Test("既定brandAccentのダーク値は黒文字がAAを満たす")
    func brandAccentDarkPrefersBlack() {
        let luminance = Self.luminanceFromSRGB(red: 95, green: 152, blue: 246)

        #expect(luminance.contrastRatio(against: .black) >= 4.5)
        #expect(luminance.contrastRatio(against: .black) > luminance.contrastRatio(against: .white))
    }

    @Test("明るい警告色では白文字を選ばない")
    func brightWarningColorDoesNotUseWhite() {
        let luminance = Self.luminanceFromSRGB(red: 255, green: 191, blue: 0)

        #expect(luminance.contrastRatio(against: .black) >= 4.5)
        #expect(luminance.contrastRatio(against: .black) > luminance.contrastRatio(against: .white))
    }

    private static func luminanceFromSRGB(red: Double, green: Double, blue: Double) -> RelativeLuminance {
        RelativeLuminance(
            linearRed: linearSRGB(red / 255),
            linearGreen: linearSRGB(green / 255),
            linearBlue: linearSRGB(blue / 255)
        )
    }

    private static func linearSRGB(_ component: Double) -> Double {
        if component <= 0.04045 {
            return component / 12.92
        }
        return pow((component + 0.055) / 1.055, 2.4)
    }
}
