//
//  BodyRegionShapeFactory.swift
//  PainPal
//
//  Created by Chapman Leung on 22/3/2026.
//

import SwiftUI

struct AnyRegionShape: Shape {
    private let builder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        self.builder = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        builder(rect)
    }
}

struct EmptyRegionShape: Shape {
    func path(in rect: CGRect) -> Path { Path() }
}

enum BodyRegionShapeFactory {
    static func shape(for location: PainLocation) -> AnyRegionShape {
        switch location {
        case .headFront: return AnyRegionShape(HeadFrontShape())
        case .face: return AnyRegionShape(FaceShape())
        case .neckFront: return AnyRegionShape(NeckFrontShape())
        case .chestLeft: return AnyRegionShape(ChestLeftShape())
        case .chestCentre: return AnyRegionShape(ChestCentreShape())
        case .chestRight: return AnyRegionShape(ChestRightShape())
        case .abdomenLeft: return AnyRegionShape(AbdomenLeftShape())
        case .abdomenCentre: return AnyRegionShape(AbdomenCentreShape())
        case .abdomenRight: return AnyRegionShape(AbdomenRightShape())
        case .pelvis: return AnyRegionShape(PelvisShape())
        case .rightShoulderFront: return AnyRegionShape(RightShoulderFrontShape())
        case .rightUpperArmFront: return AnyRegionShape(RightUpperArmFrontShape())
        case .rightForearmFront: return AnyRegionShape(RightForearmFrontShape())
        case .rightHandFront: return AnyRegionShape(RightHandFrontShape())
        case .leftShoulderFront: return AnyRegionShape(LeftShoulderFrontShape())
        case .leftUpperArmFront: return AnyRegionShape(LeftUpperArmFrontShape())
        case .leftForearmFront: return AnyRegionShape(LeftForearmFrontShape())
        case .leftHandFront: return AnyRegionShape(LeftHandFrontShape())
        case .rightThighFront: return AnyRegionShape(RightThighFrontShape())
        case .rightKneeFront: return AnyRegionShape(RightKneeFrontShape())
        case .rightShin: return AnyRegionShape(RightShinShape())
        case .rightFootFront: return AnyRegionShape(RightFootFrontShape())
        case .leftThighFront: return AnyRegionShape(LeftThighFrontShape())
        case .leftKneeFront: return AnyRegionShape(LeftKneeFrontShape())
        case .leftShin: return AnyRegionShape(LeftShinShape())
        case .leftFootFront: return AnyRegionShape(LeftFootFrontShape())
        case .headBack: return AnyRegionShape(HeadBackShape())
        case .neckBack: return AnyRegionShape(NeckBackShape())
        case .upperBackLeft: return AnyRegionShape(UpperBackLeftShape())
        case .upperBackCentre: return AnyRegionShape(UpperBackCentreShape())
        case .upperBackRight: return AnyRegionShape(UpperBackRightShape())
        case .lowerBackLeft: return AnyRegionShape(LowerBackLeftShape())
        case .lowerBackCentre: return AnyRegionShape(LowerBackCentreShape())
        case .lowerBackRight: return AnyRegionShape(LowerBackRightShape())
        case .rightGlute: return AnyRegionShape(RightGluteShape())
        case .leftGlute: return AnyRegionShape(LeftGluteShape())
        case .leftShoulderBack: return AnyRegionShape(LeftShoulderBackShape())
        case .leftUpperArmBack: return AnyRegionShape(LeftUpperArmBackShape())
        case .leftForearmBack: return AnyRegionShape(LeftForearmBackShape())
        case .leftHandBack: return AnyRegionShape(LeftHandBackShape())
        case .rightShoulderBack: return AnyRegionShape(RightShoulderBackShape())
        case .rightUpperArmBack: return AnyRegionShape(RightUpperArmBackShape())
        case .rightForearmBack: return AnyRegionShape(RightForearmBackShape())
        case .rightHandBack: return AnyRegionShape(RightHandBackShape())
        case .leftThighBack: return AnyRegionShape(LeftThighBackShape())
        case .leftCalf: return AnyRegionShape(LeftCalfShape())
        case .leftHeel: return AnyRegionShape(LeftHeelShape())
        case .rightThighBack: return AnyRegionShape(RightThighBackShape())
        case .rightCalf: return AnyRegionShape(RightCalfShape())
        case .rightHeel: return AnyRegionShape(RightHeelShape())
        }
    }
}
