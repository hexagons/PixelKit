//
//  PIXColor.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-08.
//  Copyright © 2018 Hexagons. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct LiveColor: CustomStringConvertible {
    
//    typealias LiveValueType = LiveColor.Type
    
    public var description: String {
        let _r: CGFloat = floor(CGFloat(r) * 1000) / 1000
        let _g: CGFloat = floor(CGFloat(g) * 1000) / 1000
        let _b: CGFloat = floor(CGFloat(b) * 1000) / 1000
        let _a: CGFloat = floor(CGFloat(a) * 1000) / 1000
        return "live(r:\("\(_r)".zfill(3)),g:\("\(_g)".zfill(3)),b:\("\(_b)".zfill(3)),a:\("\(_a)".zfill(3))"
    }
    
    var futureValue: () -> (CGFloat)
    public var value: CGFloat {
        return futureValue()
    }
    
    var pxv: CGFloat {
        mutating get {
            pxvCache = value
            return value
        }
    }
    var pxvIsNew: Bool {
        return pxvCache != value
    }
    var pxvCache: CGFloat? = nil
    
    public var r: LiveFloat
    public var g: LiveFloat
    public var b: LiveFloat
    public var a: LiveFloat
    
    public static var clear: LiveColor       { return LiveColor(r: 0.0, g: 0.0, b: 0.0, a: 0.0) }
    public static var clearWhite: LiveColor  { return LiveColor(r: 1.0, g: 1.0, b: 1.0, a: 0.0) }

    public static var white: LiveColor       { return LiveColor(lum: 1.0) }
    public static var lightGray: LiveColor   { return LiveColor(lum: 0.75) }
    public static var gray: LiveColor        { return LiveColor(lum: 0.5) }
    public static var darkGray: LiveColor    { return LiveColor(lum: 0.25) }
    public static var black: LiveColor       { return LiveColor(lum: 0.0) }
    
    public static var red: LiveColor         { return LiveColor(r: 1.0, g: 0.0, b: 0.0) }
    public static var orange: LiveColor      { return LiveColor(r: 1.0, g: 0.5, b: 0.0) }
    public static var yellow: LiveColor      { return LiveColor(r: 1.0, g: 1.0, b: 0.0) }
    public static var green: LiveColor       { return LiveColor(r: 0.0, g: 1.0, b: 0.0) }
    public static var cyan: LiveColor        { return LiveColor(r: 0.0, g: 1.0, b: 1.0) }
    public static var blue: LiveColor        { return LiveColor(r: 0.0, g: 0.0, b: 1.0) }
    public static var magenta: LiveColor     { return LiveColor(r: 1.0, g: 0.0, b: 1.0) }

    public enum Bits: Int, Codable {
        case _8 = 8
        case _16 = 16
        case _32 = 32
        public var mtl: MTLPixelFormat {
            switch self {
            case ._8: return .bgra8Unorm // rgba8Unorm
            case ._16: return .rgba16Float
            case ._32: return .rgba32Float
            }
        }
        public var ci: CIFormat {
            switch self {
            case ._8: return .RGBA8
            case ._16, ._32: return .RGBA16 // FIXME: 32 bit
            }
        }
        var os: OSType {
            return kCVPixelFormatType_32BGRA
        }
        var osARGB: OSType {
            return kCVPixelFormatType_32ARGB
        }
        public var max: Int {
            return NSDecimalNumber(decimal: pow(2, self.rawValue)).intValue - 1
        }
    }
    
    /*public*/ enum Space: String, Codable {
        case sRGB
        case displayP3
        public var cg: CGColorSpace {
            switch self {
            case .sRGB:
                return CGColorSpace(name: CGColorSpace.sRGB)! // CHECK non linear extended 16 bit
            case .displayP3:
                return CGColorSpace(name: CGColorSpace.displayP3)! // CHECK linear extended 16 bit
            }
        }
//            init(_ cg: CGColorSpace) {
//                switch cg.name {
//                case CGColorSpace.sRGB: self = .sRGB
//                case CGColorSpace.extendedSRGB: self = .sRGB
//                case CGColorSpace.linearSRGB: self = .sRGB
//                case CGColorSpace.extendedLinearSRGB: self = .sRGB
//                default: self = .displayP3
//                }
//            }
    }

    var space: Space {
        return Pixels.main.colorSpace
    }
    
    var _color: _Color {
        #if os(iOS)
        return uiColor
        #elseif os(macOS)
        return nsColor
        #endif
    }
    #if os(iOS)
    public var uiColor: UIColor {
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
//            switch space {
//            case .sRGB:
//                return UIColor(red: r, green: g, blue: b, alpha: a)
//            case .displayP3:
//                return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
//            }
    }
    #elseif os(macOS)
    public var nsColor: NSColor {
        return NSColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
//            switch space {
//            case .sRGB:
//                return NSColor(red: r.value, green: g.value, blue: b.value, alpha: a.value)
//            case .displayP3:
//                return NSColor(displayP3Red: r.value, green: g.value, blue: b.value, alpha: a.value)
//            }
    }
    #endif
    
    public var ciColor: CIColor {
        return CIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a), colorSpace: space.cg) ?? CIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    public var cgColor: CGColor {
        return CGColor(colorSpace: space.cg, components: list) ?? _Color.clear.cgColor
    }
    
    public var list: [CGFloat] {
        return [CGFloat(r), CGFloat(g), CGFloat(b), CGFloat(a)]
    }
    
    public var lum: LiveFloat {
        return (r + g + b) / 3
    }
    
    public var mono: LiveColor {
        return LiveColor(r: lum, g: lum, b: lum, a: a/*, space: space*/)
    }
    
//    // MARK: - Future
//
//    public init(_ futureValue: @escaping () -> (LiveColor)) {
//        r = futureValue().r
//        g = futureValue.g
//        b = futureValue.b
//        a = futureValue.a
//    }
//
//    required public init(floatLiteral value: FloatLiteralType) {
////        futureValue = { return CGFloat(value) }
//    }
    
    // MARK: - RGB
    
    public init(r: LiveFloat, g: LiveFloat, b: LiveFloat, a: LiveFloat = 1/*, space: Space = Pixels.main.colorSpace*/) {
//        self.space = space
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public init(r255: Int, g255: Int, b255: Int, a255: Int = 255/*, space: Space = Pixels.main.colorSpace*/) {
        self.r = LiveFloat(static: CGFloat(r255) / 255)
        self.g = LiveFloat(static: CGFloat(g255) / 255)
        self.b = LiveFloat(static: CGFloat(b255) / 255)
        self.a = LiveFloat(static: CGFloat(a255) / 255)
//        self.space = space
    }
    
    // MARK: - UI
    
    #if os(iOS)
    public init(_ ui: UIColor/*, space: Space = Pixels.main.colorSpace*/) {
        let ci = CIColor(color: ui)
        r = LiveFloat(static: ci.red)
        g = LiveFloat(static: ci.green)
        b = LiveFloat(static: ci.blue)
        a = LiveFloat(static: ci.alpha)
//        self.space = space
    }
    #endif

    // MARK: - NS
    
    #if os(macOS)
    public init(_ ns: NSColor/*, space: Space = Pixels.main.colorSpace*/) {
        let ci = CIColor(color: ns)
        // FIXME: Optional LiveFloat
        r = LiveFloat(static: ci?.red ?? 0.0)
        g = LiveFloat(static: ci?.green ?? 0.0)
        b = LiveFloat(static: ci?.blue ?? 0.0)
        a = LiveFloat(static: ci?.alpha ?? 0.0)
//        self.space = space
    }
    #endif
    
    // MARK: - Grayscale
    
    public init(lum: LiveFloat) {
//        self.space = Pixels.main.colorSpace
        self.r = lum
        self.g = lum
        self.b = lum
        self.a = 1.0
    }
    
    public init(val: LiveFloat) {
//        self.space = Pixels.main.colorSpace
        self.r = val
        self.g = val
        self.b = val
        self.a = val
    }
    
    // MARK: - Hue Saturaton Value
    
    public var hue: LiveFloat {
        return LiveFloat({ self.hsv().h })
    }
    public var sat: LiveFloat {
        return LiveFloat({ self.hsv().s })
    }
    public var val: LiveFloat {
        return LiveFloat({ self.hsv().v })
    }
    func hsv() -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let r = CGFloat(self.r)
        let g = CGFloat(self.g)
        let b = CGFloat(self.b)
        var h, s, v: CGFloat
        var mn, mx, d: CGFloat
        mn = r < g ? r : g
        mn = mn < b ? mn : b
        mx = r > g ? r : g
        mx = mx > b ? mx : b
        v = mx
        d = mx - mn
        if (d < 0.00001) {
            s = 0
            h = 0
            return (h: h, s: s, v: v)
        }
        if mx > 0.0 {
            s = d / mx
        } else {
            s = 0.0
            h = 0.0
            return (h: h, s: s, v: v)
        }
        if r >= mx {
            h = (g - b) / d
        } else if g >= mx {
            h = 2.0 + (b - r) / d
        } else {
            h = 4.0 + (r - g) / d
        }
        h *= 60.0
        if h < 0.0 {
            h += 360.0
        }
        h /= 360.0
        return (h: h, s: s, v: v)
    }
    
    public init(h: LiveFloat, s: LiveFloat = 1.0, v: LiveFloat = 1.0, a: LiveFloat = 1.0/*, space: Space = Pixels.main.colorSpace*/) {
        r = LiveFloat({ return LiveColor.rgb(h: CGFloat(h), s: CGFloat(s), v: CGFloat(v)).r })
        g = LiveFloat({ return LiveColor.rgb(h: CGFloat(h), s: CGFloat(s), v: CGFloat(v)).g })
        b = LiveFloat({ return LiveColor.rgb(h: CGFloat(h), s: CGFloat(s), v: CGFloat(v)).b })
        self.a = a
//        self.space = space
    }
    static func rgb(h: CGFloat, s: CGFloat, v: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        var hh, p, q, t, ff: CGFloat
        var i: Int
        if (s <= 0.0) {
            r = v
            g = v
            b = v
            return  (r: r, g: g, b: b)
        }
        hh = (h - floor(h)) * 360
        hh = hh / 60.0
        i = Int(hh)
        ff = hh - CGFloat(i)
        p = v * (1.0 - s)
        q = v * (1.0 - (s * ff))
        t = v * (1.0 - (s * (1.0 - ff)))
        switch(i) {
        case 0:
            r = v
            g = t
            b = p
        case 1:
            r = q
            g = v
            b = p
        case 2:
            r = p
            g = v
            b = t
        case 3:
            r = p
            g = q
            b = v
        case 4:
            r = t
            g = p
            b = v
        case 5:
            r = v
            g = p
            b = q
        default:
            r = v
            g = p
            b = q
        }
        return (r: r, g: g, b: b)
    }
    
    // MARK: - Hex
    
    public var hex: String {
        let hexInt: Int = (Int)(CGFloat(r)*255)<<16 | (Int)(CGFloat(g)*255)<<8 | (Int)(CGFloat(b)*255)<<0
        return String(format:"#%06x", hexInt)
    }
    
    public init(hex: String, a: CGFloat = 1/*, space: Space = Pixels.main.colorSpace*/) {
        var hex = hex
        if hex[0..<1] == "#" {
            if hex.count == 4 {
                hex = hex[1..<4]
            } else {
                hex = hex[1..<7]
            }
        }
        if hex.count == 3 {
            let r = hex[0..<1]
            let g = hex[1..<2]
            let b = hex[2..<3]
            hex = r + r + g + g + b + b
        }
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hex)
        scanner.scanHexInt32(&hexInt)
        self.r = LiveFloat(static: CGFloat((hexInt & 0xff0000) >> 16) / 255.0)
        self.g = LiveFloat(static: CGFloat((hexInt & 0xff00) >> 8) / 255.0)
        self.b = LiveFloat(static: CGFloat((hexInt & 0xff) >> 0) / 255.0)
        self.a = LiveFloat(static: a)
//        self.space = space
    }
    
    // MARK: - Pixel
    
//    init(_ pixel: [CGFloat]/*, space: Space = Pixels.main.colorSpace*/) {
//        self.space = space
//        guard pixel.count == 4 else {
//            Pixels.main.log(.error, nil, "Color: Bad Channel Count: \(pixel.count)")
//            r = 0
//            g = 0
//            b = 0
//            a = 1
//            return
//        }
//        switch Pixels.main.bits {
//        case ._8:
//            // CHECK BGRA Temp Fix
//            b = pixel[0]
//            g = pixel[1]
//            r = pixel[2]
//            a = pixel[3]
//        case ._16, ._32:
//            r = pixel[0]
//            g = pixel[1]
//            b = pixel[2]
//            a = pixel[3]
//        }
//    }
    
    // MARK: - Pure
    
    public enum Pure {
        case red
        case green
        case blue
        case alpha
        var LiveColor: LiveColor {
            switch self {
            case .red:   return .init(r: 1.0, g: 0.0, b: 0.0, a: 0.0)
            case .green: return .init(r: 0.0, g: 1.0, b: 0.0, a: 0.0)
            case .blue:  return .init(r: 0.0, g: 0.0, b: 1.0, a: 0.0)
            case .alpha: return .init(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
            }
        }
    }
    
    public var isPure: LiveBool {
        let oneCount: LiveInt = (r == 1.0 <? 1 <=> 0) + (g == 1.0 <? 1 <=> 0) + (b == 1.0 <? 1 <=> 0) + (a == 1.0 <? 1 <=> 0)
        let zeroCount: LiveInt = (r == 0.0 <? 1 <=> 0) + (g == 0.0 <? 1 <=> 0) + (b == 0.0 <? 1 <=> 0) + (a == 0.0 <? 1 <=> 0)
        return oneCount == 1 && zeroCount == 3
    }
    
    public var pure: Pure? {
        guard Bool(isPure) else { return nil }
        if CGFloat(r) == 1.0 {
            return .red
        } else if CGFloat(g) == 1.0 {
            return .green
        } else if CGFloat(b) == 1.0 {
            return .blue
        } else if CGFloat(a) == 1.0 {
            return .alpha
        } else { return nil }
    }
    
    public init(pure: Pure) {
        r = 0
        g = 0
        b = 0
        a = 0
        switch pure {
        case .red:
            r = 1
        case .green:
            g = 1
        case .blue:
            b = 1
        case .alpha:
            a = 1
        }
//        space = Pixels.main.colorSpace
    }
    
    // MARK: - Functions
    
    public func withAlpha(of alpha: LiveFloat) -> LiveColor {
        return LiveColor(r: r, g: g, b: b, a: alpha)
    }
    
    public func withHue(of hue: LiveFloat, fullySaturated: Bool = false) -> LiveColor {
        return LiveColor(h: hue, s: fullySaturated ? 1.0 : sat, v: val/*, space: space*/)
    }
    public func withSat(of sat: LiveFloat) -> LiveColor {
        return LiveColor(h: hue, s: sat, v: val/*, space: space*/)
    }
    public func withVal(of val: LiveFloat) -> LiveColor {
        return LiveColor(h: hue, s: sat, v: val/*, space: space*/)
    }
    
    public func withShiftedHue(by hueShift: LiveFloat) -> LiveColor {
        return LiveColor(h: (hue + hueShift).remainder(dividingBy: 1.0), s: sat, v: val/*, space: space*/)
    }
    
    // MARK: - Operator Overloads
    
    public static func ==  (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.r == rhs.r &&
               lhs.g == rhs.g &&
               lhs.b == rhs.b &&
               lhs.a == rhs.a
    }
    public static func != (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return !(lhs == rhs)
    }
    
    public static func > (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val > rhs.val
    }
    public static func < (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val < rhs.val
    }
    public static func >= (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val >= rhs.val
    }
    public static func <= (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val <= rhs.val
    }
    
    public static func + (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(
            r: lhs.r + rhs.r,
            g: lhs.g + rhs.g,
            b: lhs.b + rhs.b,
            a: lhs.a + rhs.a/*,
            space: lhs.space*/)
    }
    public static func - (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(
            r: lhs.r - rhs.r,
            g: lhs.g - rhs.g,
            b: lhs.b - rhs.b,
            a: lhs.a/*,
             space: lhs.space*/)
    }
    public static func -- (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(
            r: lhs.r - rhs.r,
            g: lhs.g - rhs.g,
            b: lhs.b - rhs.b,
            a: lhs.a - rhs.a/*,
             space: lhs.space*/)
    }
    public static func * (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(
            r: lhs.r * rhs.r,
            g: lhs.g * rhs.g,
            b: lhs.b * rhs.b,
            a: lhs.a * rhs.a/*,
             space: lhs.space*/)
    }
    
    public static func + (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(
            r: lhs.r + rhs,
            g: lhs.g + rhs,
            b: lhs.b + rhs,
            a: lhs.a + rhs/*,
             space: lhs.space*/)
    }
    public static func - (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(
            r: lhs.r - rhs,
            g: lhs.g - rhs,
            b: lhs.b - rhs,
            a: lhs.a/*,
             space: lhs.space*/)
    }
    public static func -- (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(
            r: lhs.r - rhs,
            g: lhs.g - rhs,
            b: lhs.b - rhs,
            a: lhs.a - rhs/*,
             space: lhs.space*/)
    }
    public static func * (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(
            r: lhs.r * rhs,
            g: lhs.g * rhs,
            b: lhs.b * rhs,
            a: lhs.a * rhs/*,
             space: lhs.space*/)
    }
    public static func / (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor({
            guard rhs.value != 0 else {
                return .init(lum: 1)
            }
            return LiveColor(
                r: lhs.r / rhs,
                g: lhs.g / rhs,
                b: lhs.b / rhs,
                a: lhs.a / rhs/*,
                 space: lhs.space*/)
        })
    }
    public static func + (lhs: LiveFloat, rhs: LiveColor) -> LiveColor {
        return rhs + lhs
    }
    public static func - (lhs: LiveFloat, rhs: LiveColor) -> LiveColor {
        return (rhs - lhs) * -1
    }
    public static func * (lhs: LiveFloat, rhs: LiveColor) -> LiveColor {
        return rhs * lhs
    }
    
//    public static func += (lhs: inout LiveColor, rhs: LiveColor) {
//        lhs.r += rhs.r
//        lhs.g += rhs.g
//        lhs.b += rhs.b
//        lhs.a += rhs.a
//    }
//    public static func -= (lhs: inout LiveColor, rhs: LiveColor) {
//        lhs.r -= rhs.r
//        lhs.g -= rhs.g
//        lhs.b -= rhs.b
//        lhs.a -= rhs.a
//    }
//    public static func *= (lhs: inout LiveColor, rhs: LiveColor) {
//        lhs.r *= rhs.r
//        lhs.g *= rhs.g
//        lhs.b *= rhs.b
//        lhs.a *= rhs.a
//    }
//
//    public static func += (lhs: inout LiveColor, rhs: LiveFloat) {
//        lhs.r += rhs
//        lhs.g += rhs
//        lhs.b += rhs
//        lhs.a += rhs
//    }
//    public static func -= (lhs: inout LiveColor, rhs: LiveFloat) {
//        lhs.r -= rhs
//        lhs.g -= rhs
//        lhs.b -= rhs
//        lhs.a -= rhs
//    }
//    public static func *= (lhs: inout LiveColor, rhs: LiveFloat) {
//        lhs.r *= rhs
//        lhs.g *= rhs
//        lhs.b *= rhs
//        lhs.a *= rhs
//    }
//    public static func /= (lhs: inout LiveColor, rhs: LiveFloat) {
//        guard rhs != 0 else { return }
//        lhs.r /= rhs
//        lhs.g /= rhs
//        lhs.b /= rhs
//        lhs.a /= rhs
//    }
    
    public prefix static func - (operand: LiveColor) -> LiveColor {
        return LiveColor(
            r: -operand.r,
            g: -operand.g,
            b: -operand.b,
            a: operand.a/*,
            space: operand.space*/)
    }
    
    public prefix static func -- (operand: LiveColor) -> LiveColor {
        return LiveColor(
            r: -operand.r,
            g: -operand.g,
            b: -operand.b,
            a: -operand.a/*,
             space: operand.space*/)
    }
    
    public prefix static func ! (operand: LiveColor) -> LiveColor {
        return LiveColor(
            r: 1.0 - operand.r,
            g: 1.0 - operand.g,
            b: 1.0 - operand.b,
            a: operand.a/*,
             space: operand.space*/)
    }
    
}

//#if os(iOS)
//typealias _Color = UIColor
//#elseif os(macOS)
//typealias _Color = NSColor
//#endif
//public extension _Color {
//    var liveColor: LiveColor {
//        return LiveColor(self)
//    }
//}

extension String {

    public subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    public subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    public func zfill(_ length: Int) -> String {
        let diff = (length - count)
        let prefix = (diff > 0 ? String(repeating: "0", count: diff) : "")
        
        return (prefix + self)
    }
    
}