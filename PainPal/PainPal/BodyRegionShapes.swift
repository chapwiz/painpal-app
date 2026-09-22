
//
//  BodyRegionShapes.swift
//  PainPal
//
//  Created by Chapman Leung on 22/3/2026.
//

import SwiftUI

struct HeadFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 92.0
        let sy = rect.height / 97.0

        var path = Path()
        path.move(to: CGPoint(x: 45.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 17.6 * sx, y: 0.6 * sy),
            control2: CGPoint(x: 0.6 * sx, y: 22.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 45.6 * sx, y: 95.6 * sy),
            control1: CGPoint(x: 0.6 * sx, y: 78.6 * sy),
            control2: CGPoint(x: 17.6 * sx, y: 95.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 90.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 73.6 * sx, y: 95.6 * sy),
            control2: CGPoint(x: 90.6 * sx, y: 78.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 45.6 * sx, y: 0.6 * sy),
            control1: CGPoint(x: 90.6 * sx, y: 22.6 * sy),
            control2: CGPoint(x: 73.6 * sx, y: 0.6 * sy)
        )
        path.closeSubpath()
        return path
    }
}

struct FaceShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 52.0
        let sy = rect.height / 77.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 30.6 * sy))
        path.addCurve(
            to: CGPoint(x: 25.6 * sx, y: 75.6 * sy),
            control1: CGPoint(x: 0.6 * sx, y: 55.6 * sy),
            control2: CGPoint(x: 10.6 * sx, y: 75.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 50.6 * sx, y: 30.6 * sy),
            control1: CGPoint(x: 40.6 * sx, y: 75.6 * sy),
            control2: CGPoint(x: 50.6 * sx, y: 55.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 25.6 * sx, y: 0.6 * sy),
            control1: CGPoint(x: 50.6 * sx, y: 5.6 * sy),
            control2: CGPoint(x: 40.6 * sx, y: 0.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 30.6 * sy),
            control1: CGPoint(x: 10.6 * sx, y: 0.6 * sy),
            control2: CGPoint(x: 0.6 * sx, y: 5.6 * sy)
        )
        path.closeSubpath()
        return path
    }
}

struct NeckFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 19.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 10.6 * sy))
        path.addCurve(
            to: CGPoint(x: 30.6 * sx, y: 10.6 * sy),
            control1: CGPoint(x: 2.6 * sx, y: 20.6 * sy),
            control2: CGPoint(x: 28.6 * sx, y: 20.6 * sy)
        )
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 10.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct ChestRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 52.0

        var path = Path()
        path.move(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 35.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 15.6 * sx, y: 5.6 * sy),
            control2: CGPoint(x: 0.6 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 50.6 * sy))
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct ChestCentreShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 52.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 50.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 50.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct ChestLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 52.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 25.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 60.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 45.6 * sx, y: 5.6 * sy),
            control2: CGPoint(x: 60.6 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 50.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct AbdomenRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 57.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 15.6 * sx, y: 55.6 * sy),
            control1: CGPoint(x: 0.6 * sx, y: 25.6 * sy),
            control2: CGPoint(x: 5.6 * sx, y: 45.6 * sy)
        )
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 55.6 * sy))
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct AbdomenCentreShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 57.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 55.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 55.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct AbdomenLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 57.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 55.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 55.6 * sy))
        path.addCurve(
            to: CGPoint(x: 60.6 * sx, y: 0.6 * sy),
            control1: CGPoint(x: 55.6 * sx, y: 45.6 * sy),
            control2: CGPoint(x: 60.6 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct PelvisShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 122.0
        let sy = rect.height / 37.0

        var path = Path()
        path.move(to: CGPoint(x: 0.886223 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 60.8862 * sx, y: 35.6 * sy),
            control1: CGPoint(x: 10.8862 * sx, y: 25.6 * sy),
            control2: CGPoint(x: 30.8862 * sx, y: 35.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 120.886 * sx, y: 0.6 * sy),
            control1: CGPoint(x: 90.8862 * sx, y: 35.6 * sy),
            control2: CGPoint(x: 110.886 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 0.886223 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightShoulderFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 33.0

        var path = Path()
        path.move(to: CGPoint(x: 45.9166 * sx, y: 1.91627 * sy))
        path.addCurve(
            to: CGPoint(x: 0.916565 * sx, y: 16.7583 * sy),
            control1: CGPoint(x: 23.4166 * sx, y: -3.03108 * sy),
            control2: CGPoint(x: 8.41656 * sx, y: 6.86361 * sy)
        )
        path.addLine(to: CGPoint(x: 30.9166 * sx, y: 31.6003 * sy))
        path.addLine(to: CGPoint(x: 45.9166 * sx, y: 1.91627 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightUpperArmFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 42.0
        let sy = rect.height / 67.0

        var path = Path()
        path.move(to: CGPoint(x: 10.6873 * sx, y: 0.9 * sy))
        path.addLine(to: CGPoint(x: 0.687347 * sx, y: 60.9 * sy))
        path.addLine(to: CGPoint(x: 25.6873 * sx, y: 65.9 * sy))
        path.addLine(to: CGPoint(x: 40.6873 * sx, y: 15.9 * sy))
        path.addLine(to: CGPoint(x: 10.6873 * sx, y: 0.9 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightForearmFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 62.0

        var path = Path()
        path.move(to: CGPoint(x: 5.64406 * sx, y: 0.719299 * sy))
        path.addLine(to: CGPoint(x: 0.644058 * sx, y: 55.7193 * sy))
        path.addLine(to: CGPoint(x: 20.6441 * sx, y: 60.7193 * sy))
        path.addLine(to: CGPoint(x: 30.6441 * sx, y: 5.7193 * sy))
        path.addLine(to: CGPoint(x: 5.64406 * sx, y: 0.719299 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightHandFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 29.0

        var path = Path()
        path.move(to: CGPoint(x: 1.25403 * sx, y: 5.69882 * sy))
        path.addCurve(
            to: CGPoint(x: 31.254 * sx, y: 20.6988 * sy),
            control1: CGPoint(x: -3.74597 * sx, y: 25.6988 * sy),
            control2: CGPoint(x: 21.254 * sx, y: 35.6988 * sy)
        )
        path.addLine(to: CGPoint(x: 21.254 * sx, y: 0.698822 * sy))
        path.addLine(to: CGPoint(x: 1.25403 * sx, y: 5.69882 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftShoulderFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 33.0

        var path = Path()
        path.move(to: CGPoint(x: 0.884421 * sx, y: 1.91627 * sy))
        path.addCurve(
            to: CGPoint(x: 45.8844 * sx, y: 16.7583 * sy),
            control1: CGPoint(x: 23.3844 * sx, y: -3.03108 * sy),
            control2: CGPoint(x: 38.3844 * sx, y: 6.86361 * sy)
        )
        path.addLine(to: CGPoint(x: 15.8844 * sx, y: 31.6003 * sy))
        path.addLine(to: CGPoint(x: 0.884421 * sx, y: 1.91627 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftUpperArmFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 42.0
        let sy = rect.height / 67.0

        var path = Path()
        path.move(to: CGPoint(x: 30.7197 * sx, y: 0.9 * sy))
        path.addLine(to: CGPoint(x: 40.7197 * sx, y: 60.9 * sy))
        path.addLine(to: CGPoint(x: 15.7197 * sx, y: 65.9 * sy))
        path.addLine(to: CGPoint(x: 0.719707 * sx, y: 15.9 * sy))
        path.addLine(to: CGPoint(x: 30.7197 * sx, y: 0.9 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftForearmFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 62.0

        var path = Path()
        path.move(to: CGPoint(x: 25.6958 * sx, y: 0.719299 * sy))
        path.addLine(to: CGPoint(x: 30.6958 * sx, y: 55.7193 * sy))
        path.addLine(to: CGPoint(x: 10.6958 * sx, y: 60.7193 * sy))
        path.addLine(to: CGPoint(x: 0.695786 * sx, y: 5.7193 * sy))
        path.addLine(to: CGPoint(x: 25.6958 * sx, y: 0.719299 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftHandFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 29.0

        var path = Path()
        path.move(to: CGPoint(x: 30.6924 * sx, y: 5.69882 * sy))
        path.addCurve(
            to: CGPoint(x: 0.692371 * sx, y: 20.6988 * sy),
            control1: CGPoint(x: 35.6924 * sx, y: 25.6988 * sy),
            control2: CGPoint(x: 10.6924 * sx, y: 35.6988 * sy)
        )
        path.addLine(to: CGPoint(x: 10.6924 * sx, y: 0.698822 * sy))
        path.addLine(to: CGPoint(x: 30.6924 * sx, y: 5.69882 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightThighFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 111.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 1.83279 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 109.833 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 109.833 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 26.3328 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 1.83279 * sy),
            control1: CGPoint(x: 19.1 * sx, y: 22.8328 * sy),
            control2: CGPoint(x: 11.6 * sx, y: 16.8328 * sy)
        )
        path.closeSubpath()
        return path
    }
}

struct RightKneeFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 23.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 21.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 21.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightShinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 82.0

        var path = Path()
        path.move(to: CGPoint(x: 0.638672 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 5.63867 * sx, y: 80.6 * sy))
        path.addLine(to: CGPoint(x: 45.6387 * sx, y: 80.6 * sy))
        path.addLine(to: CGPoint(x: 45.6387 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.638672 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightFootFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 43.0
        let sy = rect.height / 27.0

        var path = Path()
        path.move(to: CGPoint(x: 1.54751 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 41.5475 * sx, y: 25.6 * sy),
            control1: CGPoint(x: -3.45249 * sx, y: 15.6 * sy),
            control2: CGPoint(x: 11.5475 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 41.5475 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 1.54751 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftThighFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 111.0

        var path = Path()
        path.move(to: CGPoint(x: 45.6 * sx, y: 1.74872 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 110.249 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 110.249 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 24.7487 * sy))
        path.addCurve(
            to: CGPoint(x: 45.6 * sx, y: 1.74872 * sy),
            control1: CGPoint(x: 20.6 * sx, y: 24.7487 * sy),
            control2: CGPoint(x: 35.1 * sx, y: 15.2487 * sy)
        )
        path.closeSubpath()
        return path
    }
}

struct LeftKneeFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 22.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 20.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 20.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftShinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 82.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 80.6 * sy))
        path.addLine(to: CGPoint(x: 40.6 * sx, y: 80.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftFootFrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 43.0
        let sy = rect.height / 27.0

        var path = Path()
        path.move(to: CGPoint(x: 40.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 25.6 * sy),
            control1: CGPoint(x: 45.6 * sx, y: 15.6 * sy),
            control2: CGPoint(x: 30.6 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 40.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct HeadBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 92.0
        let sy = rect.height / 97.0

        var path = Path()
        path.move(to: CGPoint(x: 45.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 17.6 * sx, y: 0.6 * sy),
            control2: CGPoint(x: 0.6 * sx, y: 22.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 45.6 * sx, y: 95.6 * sy),
            control1: CGPoint(x: 0.6 * sx, y: 78.6 * sy),
            control2: CGPoint(x: 17.6 * sx, y: 95.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 90.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 73.6 * sx, y: 95.6 * sy),
            control2: CGPoint(x: 90.6 * sx, y: 78.6 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 45.6 * sx, y: 0.6 * sy),
            control1: CGPoint(x: 90.6 * sx, y: 22.6 * sy),
            control2: CGPoint(x: 73.6 * sx, y: 0.6 * sy)
        )
        path.closeSubpath()
        return path
    }
}

struct NeckBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 19.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 10.6 * sy))
        path.addCurve(
            to: CGPoint(x: 30.6 * sx, y: 10.6 * sy),
            control1: CGPoint(x: 2.6 * sx, y: 20.6 * sy),
            control2: CGPoint(x: 28.6 * sx, y: 20.6 * sy)
        )
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 10.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct UpperBackLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 52.0

        var path = Path()
        path.move(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 35.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 15.6 * sx, y: 5.6 * sy),
            control2: CGPoint(x: 0.6 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 50.6 * sy))
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct UpperBackCentreShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 52.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 50.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 50.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct UpperBackRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 52.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 25.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 60.6 * sx, y: 50.6 * sy),
            control1: CGPoint(x: 45.6 * sx, y: 5.6 * sy),
            control2: CGPoint(x: 60.6 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 50.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LowerBackLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 57.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 15.6 * sx, y: 55.6 * sy),
            control1: CGPoint(x: 0.6 * sx, y: 25.6 * sy),
            control2: CGPoint(x: 5.6 * sx, y: 45.6 * sy)
        )
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 55.6 * sy))
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LowerBackCentreShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 57.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 30.6 * sx, y: 55.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 55.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LowerBackRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 57.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 55.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 55.6 * sy))
        path.addCurve(
            to: CGPoint(x: 60.6 * sx, y: 0.6 * sy),
            control1: CGPoint(x: 55.6 * sx, y: 45.6 * sy),
            control2: CGPoint(x: 60.6 * sx, y: 25.6 * sy)
        )
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftGluteShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 37.0

        var path = Path()
        path.move(to: CGPoint(x: 0.88623 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 60.8862 * sx, y: 35.6 * sy),
            control1: CGPoint(x: 10.8862 * sx, y: 25.6 * sy),
            control2: CGPoint(x: 30.8862 * sx, y: 35.6 * sy)
        )
        path.addLine(to: CGPoint(x: 60.8862 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.88623 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightGluteShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 62.0
        let sy = rect.height / 37.0

        var path = Path()
        path.move(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 35.6 * sy),
            control1: CGPoint(x: 50.6 * sx, y: 25.6 * sy),
            control2: CGPoint(x: 30.6 * sx, y: 35.6 * sy)
        )
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 60.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftShoulderBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 33.0

        var path = Path()
        path.move(to: CGPoint(x: 45.9166 * sx, y: 1.91627 * sy))
        path.addCurve(
            to: CGPoint(x: 0.916565 * sx, y: 16.7583 * sy),
            control1: CGPoint(x: 23.4166 * sx, y: -3.03108 * sy),
            control2: CGPoint(x: 8.41656 * sx, y: 6.86361 * sy)
        )
        path.addLine(to: CGPoint(x: 30.9166 * sx, y: 31.6003 * sy))
        path.addLine(to: CGPoint(x: 45.9166 * sx, y: 1.91627 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftUpperArmBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 42.0
        let sy = rect.height / 67.0

        var path = Path()
        path.move(to: CGPoint(x: 10.6873 * sx, y: 0.9 * sy))
        path.addLine(to: CGPoint(x: 0.687347 * sx, y: 60.9 * sy))
        path.addLine(to: CGPoint(x: 25.6873 * sx, y: 65.9 * sy))
        path.addLine(to: CGPoint(x: 40.6873 * sx, y: 15.9 * sy))
        path.addLine(to: CGPoint(x: 10.6873 * sx, y: 0.9 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftForearmBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 62.0

        var path = Path()
        path.move(to: CGPoint(x: 5.64406 * sx, y: 0.719299 * sy))
        path.addLine(to: CGPoint(x: 0.644058 * sx, y: 55.7193 * sy))
        path.addLine(to: CGPoint(x: 20.6441 * sx, y: 60.7193 * sy))
        path.addLine(to: CGPoint(x: 30.6441 * sx, y: 5.7193 * sy))
        path.addLine(to: CGPoint(x: 5.64406 * sx, y: 0.719299 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftHandBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 29.0

        var path = Path()
        path.move(to: CGPoint(x: 1.25403 * sx, y: 5.69882 * sy))
        path.addCurve(
            to: CGPoint(x: 31.254 * sx, y: 20.6988 * sy),
            control1: CGPoint(x: -3.74597 * sx, y: 25.6988 * sy),
            control2: CGPoint(x: 21.254 * sx, y: 35.6988 * sy)
        )
        path.addLine(to: CGPoint(x: 21.254 * sx, y: 0.698822 * sy))
        path.addLine(to: CGPoint(x: 1.25403 * sx, y: 5.69882 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightShoulderBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 33.0

        var path = Path()
        path.move(to: CGPoint(x: 0.88443 * sx, y: 1.91627 * sy))
        path.addCurve(
            to: CGPoint(x: 45.8844 * sx, y: 16.7583 * sy),
            control1: CGPoint(x: 23.3844 * sx, y: -3.03108 * sy),
            control2: CGPoint(x: 38.3844 * sx, y: 6.86361 * sy)
        )
        path.addLine(to: CGPoint(x: 15.8844 * sx, y: 31.6003 * sy))
        path.addLine(to: CGPoint(x: 0.88443 * sx, y: 1.91627 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightUpperArmBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 42.0
        let sy = rect.height / 67.0

        var path = Path()
        path.move(to: CGPoint(x: 30.7197 * sx, y: 0.9 * sy))
        path.addLine(to: CGPoint(x: 40.7197 * sx, y: 60.9 * sy))
        path.addLine(to: CGPoint(x: 15.7197 * sx, y: 65.9 * sy))
        path.addLine(to: CGPoint(x: 0.719696 * sx, y: 15.9 * sy))
        path.addLine(to: CGPoint(x: 30.7197 * sx, y: 0.9 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightForearmBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 62.0

        var path = Path()
        path.move(to: CGPoint(x: 25.6958 * sx, y: 0.719299 * sy))
        path.addLine(to: CGPoint(x: 30.6958 * sx, y: 55.7193 * sy))
        path.addLine(to: CGPoint(x: 10.6958 * sx, y: 60.7193 * sy))
        path.addLine(to: CGPoint(x: 0.695801 * sx, y: 5.7193 * sy))
        path.addLine(to: CGPoint(x: 25.6958 * sx, y: 0.719299 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightHandBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 32.0
        let sy = rect.height / 29.0

        var path = Path()
        path.move(to: CGPoint(x: 30.6924 * sx, y: 5.69882 * sy))
        path.addCurve(
            to: CGPoint(x: 0.692383 * sx, y: 20.6988 * sy),
            control1: CGPoint(x: 35.6924 * sx, y: 25.6988 * sy),
            control2: CGPoint(x: 10.6924 * sx, y: 35.6988 * sy)
        )
        path.addLine(to: CGPoint(x: 10.6924 * sx, y: 0.698822 * sy))
        path.addLine(to: CGPoint(x: 30.6924 * sx, y: 5.69882 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftThighBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 118.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 2.082 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 116.582 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 116.582 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 26.5821 * sy))
        path.addCurve(
            to: CGPoint(x: 0.6 * sx, y: 2.082 * sy),
            control1: CGPoint(x: 27.6 * sx, y: 24.082 * sy),
            control2: CGPoint(x: 11.6 * sx, y: 19.582 * sy)
        )
        path.closeSubpath()
        return path
    }
}

struct LeftCalfShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 97.0

        var path = Path()
        path.move(to: CGPoint(x: 0.632416 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 5.63242 * sx, y: 95.6 * sy))
        path.addLine(to: CGPoint(x: 45.6324 * sx, y: 95.6 * sy))
        path.addLine(to: CGPoint(x: 45.6324 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.632416 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct LeftHeelShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 42.0
        let sy = rect.height / 22.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 20.6 * sy))
        path.addLine(to: CGPoint(x: 40.6 * sx, y: 20.6 * sy))
        path.addLine(to: CGPoint(x: 40.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightThighBackShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 119.0

        var path = Path()
        path.move(to: CGPoint(x: 45.6 * sx, y: 2.03867 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 117.539 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 117.539 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 24.7487 * sy))
        path.addCurve(
            to: CGPoint(x: 45.6 * sx, y: 1.74872 * sy),
            control1: CGPoint(x: 20.6 * sx, y: 24.3487 * sy),
            control2: CGPoint(x: 35.1 * sx, y: 15.2487 * sy)
        )
        path.closeSubpath()
        return path
    }
}

struct RightCalfShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 47.0
        let sy = rect.height / 97.0

        var path = Path()
        path.move(to: CGPoint(x: 45.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 40.6 * sx, y: 95.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 95.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 45.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}

struct RightHeelShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 42.0
        let sy = rect.height / 22.0

        var path = Path()
        path.move(to: CGPoint(x: 0.6 * sx, y: 0.6 * sy))
        path.addLine(to: CGPoint(x: 0.6 * sx, y: 20.6 * sy))
        path.addLine(to: CGPoint(x: 40.6 * sx, y: 20.6 * sy))
        path.addLine(to: CGPoint(x: 40.6 * sx, y: 0.6 * sy))
        path.closeSubpath()
        return path
    }
}
