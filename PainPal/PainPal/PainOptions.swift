//
//  PainOptions.swift
//  PainPal
//
//  Created by Chapman Leung on 18/1/2026.
//



//
//  PainOptions.swift
//  PainPal
//
//  Created by Chapman Leung on 18/1/2026.
//

import Foundation


enum PainScale: String, CaseIterable, Identifiable, Codable {
    case wongBaker = "Wong-Baker"
    case rFLACC = "r-FLACC"
    var id: String { rawValue }
}

enum PainTrend: String, CaseIterable, Identifiable, Codable {
    case better = "Better"
    case same = "Same"
    case worse = "Worse"

    var id: String { rawValue }
}

enum PainLocation: String, CaseIterable, Identifiable, Codable {
    case headFront
    case face
    case neckFront
    case leftShoulderFront
    case rightShoulderFront
    case chestLeft
    case chestCentre
    case chestRight
    case abdomenLeft
    case abdomenCentre
    case abdomenRight
    case pelvis
    case leftUpperArmFront
    case rightUpperArmFront
    case leftForearmFront
    case rightForearmFront
    case leftHandFront
    case rightHandFront
    case leftThighFront
    case rightThighFront
    case leftKneeFront
    case rightKneeFront
    case leftShin
    case rightShin
    case leftFootFront
    case rightFootFront

    case headBack
    case neckBack
    case leftShoulderBack
    case rightShoulderBack
    case upperBackLeft
    case upperBackCentre
    case upperBackRight
    case lowerBackLeft
    case lowerBackCentre
    case lowerBackRight
    case leftUpperArmBack
    case rightUpperArmBack
    case leftForearmBack
    case rightForearmBack
    case leftHandBack
    case rightHandBack
    case leftGlute
    case rightGlute
    case leftThighBack
    case rightThighBack
    case leftCalf
    case rightCalf
    case leftHeel
    case rightHeel

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .headFront: return "Head (front)"
        case .face: return "Face"
        case .neckFront: return "Neck (front)"
        case .leftShoulderFront: return "Left shoulder (front)"
        case .rightShoulderFront: return "Right shoulder (front)"
        case .chestLeft: return "Left chest"
        case .chestCentre: return "Centre chest"
        case .chestRight: return "Right chest"
        case .abdomenLeft: return "Left abdomen"
        case .abdomenCentre: return "Centre abdomen"
        case .abdomenRight: return "Right abdomen"
        case .pelvis: return "Pelvis"
        case .leftUpperArmFront: return "Left upper arm (front)"
        case .rightUpperArmFront: return "Right upper arm (front)"
        case .leftForearmFront: return "Left forearm (front)"
        case .rightForearmFront: return "Right forearm (front)"
        case .leftHandFront: return "Left hand (front)"
        case .rightHandFront: return "Right hand (front)"
        case .leftThighFront: return "Left thigh (front)"
        case .rightThighFront: return "Right thigh (front)"
        case .leftKneeFront: return "Left knee (front)"
        case .rightKneeFront: return "Right knee (front)"
        case .leftShin: return "Left shin"
        case .rightShin: return "Right shin"
        case .leftFootFront: return "Left foot (front)"
        case .rightFootFront: return "Right foot (front)"
        case .headBack: return "Head (back)"
        case .neckBack: return "Neck (back)"
        case .leftShoulderBack: return "Left shoulder (back)"
        case .rightShoulderBack: return "Right shoulder (back)"
        case .upperBackLeft: return "Left upper back"
        case .upperBackCentre: return "Centre upper back"
        case .upperBackRight: return "Right upper back"
        case .lowerBackLeft: return "Left lower back"
        case .lowerBackCentre: return "Centre lower back"
        case .lowerBackRight: return "Right lower back"
        case .leftUpperArmBack: return "Left upper arm (back)"
        case .rightUpperArmBack: return "Right upper arm (back)"
        case .leftForearmBack: return "Left forearm (back)"
        case .rightForearmBack: return "Right forearm (back)"
        case .leftHandBack: return "Left hand (back)"
        case .rightHandBack: return "Right hand (back)"
        case .leftGlute: return "Left buttock"
        case .rightGlute: return "Right buttock"
        case .leftThighBack: return "Left thigh (back)"
        case .rightThighBack: return "Right thigh (back)"
        case .leftCalf: return "Left calf"
        case .rightCalf: return "Right calf"
        case .leftHeel: return "Left heel"
        case .rightHeel: return "Right heel"
        }
    }
}

enum PainQuality: String, CaseIterable, Identifiable, Codable {
    case sharp = "Sharp"
    case dull = "Dull"
    case throbbing = "Throbbing"
    case burning = "Burning"
    case aching = "Aching"
    case stabbing = "Stabbing"
    case cramping = "Cramping"
    case sore = "Sore"
    case tight = "Tight"
    case pressure = "Pressure"

    var id: String { rawValue }
}

enum Symptom: String, CaseIterable, Identifiable, Codable {
    case nausea = "Nausea"
    case vomiting = "Vomiting"
    case fever = "Fever"
    case dizziness = "Dizziness"
    case headache = "Headache"
    case swelling = "Swelling"
    case redness = "Redness"
    case bruising = "Bruising"
    case numbness = "Numbness"
    case tingling = "Tingling"
    case weakness = "Weakness"
    case shortnessOfBreath = "Shortness of breath"
    case cough = "Cough"
    case diarrhoea = "Diarrhoea"

    var id: String { rawValue }
}

enum Trigger: String, CaseIterable, Identifiable, Codable {
    case movement = "Movement"
    case touch = "Touch"
    case eating = "Eating"
    case crying = "Crying"
    case coughing = "Coughing"
    case walking = "Walking"
    case sitting = "Sitting"
    case standing = "Standing"
    case lyingDown = "Lying down"
    case brightLight = "Bright light"
    case noise = "Noise"

    var id: String { rawValue }
}

enum Reliever: String, CaseIterable, Identifiable, Codable {
    case rest = "Rest"
    case ice = "Ice"
    case heat = "Heat"
    case massage = "Massage"
    case positionChange = "Position change"
    case medicine = "Medicine"
    case hydration = "Hydration"
    case food = "Food"
    case distraction = "Distraction"
    case breathing = "Breathing"

    var id: String { rawValue }
}
