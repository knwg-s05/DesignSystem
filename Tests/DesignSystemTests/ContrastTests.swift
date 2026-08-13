import Foundation
import Testing
@testable import DesignSystem

@Suite("コントラスト計算")
struct ContrastTests {

    private static let tintSamples: [TintSample] = [
        TintSample(name: "brandAccent light", red: 37, green: 102, blue: 229),
        TintSample(name: "brandAccent dark", red: 95, green: 152, blue: 246),
        TintSample(name: "orange iOS 18", red: 255, green: 149, blue: 0),
        TintSample(name: "orange iOS 26", red: 255, green: 141, blue: 40),
        TintSample(name: "yellow", red: 255, green: 204, blue: 0),
        TintSample(name: "green", red: 52, green: 199, blue: 89),
        TintSample(name: "pink", red: 255, green: 45, blue: 85),
    ]

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

    @Test("PrimaryButtonStyleは主色5色でAAを満たす文字色を選べる", arguments: tintSamples)
    private func primaryButtonCanChooseAAForeground(_ sample: TintSample) {
        let background = sample.luminance
        let againstWhite = background.contrastRatio(against: .white)
        let againstBlack = background.contrastRatio(against: .black)

        #expect(max(againstWhite, againstBlack) >= 4.5)
    }

    @Test("SecondaryButtonStyleは薄い主色面と本文色の組み合わせでAAを満たす", arguments: tintSamples)
    private func secondaryButtonContentPrimaryContrast(_ sample: TintSample) {
        let lightModeBackground = sample.blendedLuminance(over: .white, alpha: 0.15)
        let darkModeBackground = sample.blendedLuminance(over: .black, alpha: 0.15)

        #expect(lightModeBackground.contrastRatio(against: .black) >= 4.5)
        #expect(darkModeBackground.contrastRatio(against: .white) >= 4.5)
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

    private struct TintSample: Sendable, CustomTestStringConvertible {
        let name: String
        let red: Double
        let green: Double
        let blue: Double

        var testDescription: String { name }

        var luminance: RelativeLuminance {
            luminanceFromSRGB(red: red, green: green, blue: blue)
        }

        func blendedLuminance(over background: Background, alpha: Double) -> RelativeLuminance {
            let blendedRed = blend(foreground: red, background: background.red, alpha: alpha)
            let blendedGreen = blend(foreground: green, background: background.green, alpha: alpha)
            let blendedBlue = blend(foreground: blue, background: background.blue, alpha: alpha)

            return luminanceFromSRGB(red: blendedRed, green: blendedGreen, blue: blendedBlue)
        }

        private func blend(foreground: Double, background: Double, alpha: Double) -> Double {
            foreground * alpha + background * (1 - alpha)
        }
    }

    private struct Background: Sendable {
        let red: Double
        let green: Double
        let blue: Double

        static let white = Background(red: 255, green: 255, blue: 255)
        static let black = Background(red: 0, green: 0, blue: 0)
    }
}
