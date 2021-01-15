//
//  AveragePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import CoreGraphics
import RenderKit

/// Useful with **VoxelKit** to downsample depth images.
public class AveragePIX: PIXSingleEffect {

    override open var shaderName: String { return "effectSingleAveragePIX" }

    // MARK: - Public Properties

    public enum Axis: Floatable {
        case x
        case y
        case z
        var index: Int {
            switch self {
            case .x: return 0
            case .y: return 1
            case .z: return 2
            }
        }
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    @Live public var axis: Axis = .z

    // MARK: - Property Helpers

    public override var liveList: [LiveProp] {
        [_axis]
    }

    public override var values: [Floatable] {
        [axis]
    }

    public required init() {
        super.init(name: "Average", typeName: "")
    }

}
