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
    case head = "Head"
    case face = "Face"
    case neck = "Neck"
    case chest = "Chest"
    case upperBack = "Upper back"
    case lowerBack = "Lower back"
    case shoulder = "Shoulder"
    case arm = "Arm"
    case elbow = "Elbow"
    case wrist = "Wrist"
    case hand = "Hand"
    case abdomen = "Abdomen"
    case hip = "Hip"
    case groin = "Groin"
    case thigh = "Thigh"
    case knee = "Knee"
    case calf = "Calf"
    case ankle = "Ankle"
    case foot = "Foot"

    var id: String { rawValue }
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
