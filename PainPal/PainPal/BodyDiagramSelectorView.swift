//
//  BodyDiagramSelectorView.swift
//  PainPal
//
//  Created by Chapman Leung on 21/3/2026.
//

import SwiftUI

private enum DiagramBodySide: String, CaseIterable, Identifiable {
    case front = "Front"
    case back = "Back"

    var id: String { rawValue }
}

private struct RegionPlacement {
    let origin: CGPoint
    let size: CGSize
}

struct BodyDiagramSelectorView: View {
    @Binding var selectedLocations: Set<PainLocation>
    @State private var side: DiagramBodySide = .front
    @State private var displayedSide: DiagramBodySide = .front
    @State private var flipDegrees: Double = 0
    @State private var isFlipping = false

    private let canvasSize = CGSize(width: 250, height: 460)

    private var sideIndicators: (left: String, right: String) {
        switch side {
        case .front:
            return (left: "R", right: "L")
        case .back:
            return (left: "L", right: "R")
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            Picker("Body View", selection: $side) {
                ForEach(DiagramBodySide.allCases) { bodySide in
                    Text(bodySide.rawValue).tag(bodySide)
                }
            }
            .pickerStyle(.segmented)
            .disabled(isFlipping)
            .onChange(of: side) { newSide in
                guard newSide != displayedSide else { return }
                animateFlip(to: newSide)
            }

            GeometryReader { geometry in
                let scale = min(1, min(geometry.size.width / canvasSize.width, geometry.size.height / canvasSize.height))
                let renderedSize = CGSize(
                    width: canvasSize.width * scale,
                    height: canvasSize.height * scale
                )

                HStack(spacing: 12) {
                    Text(sideIndicators.left)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 28)

                    ZStack(alignment: .topLeading) {
                        ForEach(regionDrawOrder, id: \.self) { location in
                            let placement = placement(for: location)
                            let shape = BodyRegionShapeFactory.shape(for: location)
                            let regionWidth = placement.size.width * scale
                            let regionHeight = placement.size.height * scale
                            let regionX = placement.origin.x * scale
                            let regionY = placement.origin.y * scale

                            shape
                                .fill(
                                    selectedLocations.contains(location)
                                    ? Color.red.opacity(0.28)
                                    : Color(red: 0.976, green: 0.945, blue: 0.925)
                                )
                                .overlay(
                                    shape.stroke(
                                        selectedLocations.contains(location)
                                        ? Color.red
                                        : Color(red: 0.737, green: 0.667, blue: 0.643),
                                        lineWidth: selectedLocations.contains(location) ? 2 : 1.2
                                    )
                                )
                                .frame(width: regionWidth, height: regionHeight)
                                .contentShape(shape)
                                .offset(x: regionX, y: regionY)
                                .onTapGesture {
                                    toggle(location)
                                }
                                .zIndex(zIndex(for: location))
                                .accessibilityLabel(location.displayName)
                                .accessibilityAddTraits(.isButton)
                        }
                    }
                    .frame(width: renderedSize.width, height: renderedSize.height, alignment: .topLeading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .rotation3DEffect(
                        .degrees(flipDegrees),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.7
                    )

                    Text(sideIndicators.right)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 28)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.top, 4)
            }
            .frame(minHeight: 468)
            .frame(maxWidth: .infinity)

            if !selectedLocations.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected locations")
                        .font(.headline)

                    Text(selectedLocations.map(\.displayName).sorted().joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var testRegions: [PainLocation] {
        switch displayedSide {
        case .front:
            return [
                .headFront,
                .face,
                .neckFront,
                .chestLeft,
                .chestCentre,
                .chestRight,
                .abdomenLeft,
                .abdomenCentre,
                .abdomenRight,
                .pelvis,
                .rightShoulderFront,
                .rightUpperArmFront,
                .rightForearmFront,
                .rightHandFront,
                .leftShoulderFront,
                .leftUpperArmFront,
                .leftForearmFront,
                .leftHandFront,
                .rightThighFront,
                .rightKneeFront,
                .rightShin,
                .rightFootFront,
                .leftThighFront,
                .leftKneeFront,
                .leftShin,
                .leftFootFront
            ]
        case .back:
            return [
                .headBack,
                .neckBack,
                .upperBackLeft,
                .upperBackCentre,
                .upperBackRight,
                .lowerBackLeft,
                .lowerBackCentre,
                .lowerBackRight,
                .rightGlute,
                .leftGlute,
                .leftShoulderBack,
                .leftUpperArmBack,
                .leftForearmBack,
                .leftHandBack,
                .rightShoulderBack,
                .rightUpperArmBack,
                .rightForearmBack,
                .rightHandBack,
                .leftThighBack,
                .leftCalf,
                .leftHeel,
                .rightThighBack,
                .rightCalf,
                .rightHeel
            ]
        }
    }

    private var regionDrawOrder: [PainLocation] {
        switch displayedSide {
        case .front:
            return [
                .headFront,
                .chestLeft,
                .chestCentre,
                .chestRight,
                .abdomenLeft,
                .abdomenCentre,
                .abdomenRight,
                .pelvis,
                .rightShoulderFront,
                .rightUpperArmFront,
                .rightForearmFront,
                .rightHandFront,
                .leftShoulderFront,
                .leftUpperArmFront,
                .leftForearmFront,
                .leftHandFront,
                .rightThighFront,
                .rightKneeFront,
                .rightShin,
                .rightFootFront,
                .leftThighFront,
                .leftKneeFront,
                .leftShin,
                .leftFootFront,
                .face,
                .neckFront
            ]
        case .back:
            return [
                .headBack,
                .upperBackLeft,
                .upperBackCentre,
                .upperBackRight,
                .lowerBackLeft,
                .lowerBackCentre,
                .lowerBackRight,
                .rightGlute,
                .leftGlute,
                .leftShoulderBack,
                .leftUpperArmBack,
                .leftForearmBack,
                .leftHandBack,
                .rightShoulderBack,
                .rightUpperArmBack,
                .rightForearmBack,
                .rightHandBack,
                .leftThighBack,
                .leftCalf,
                .leftHeel,
                .rightThighBack,
                .rightCalf,
                .rightHeel,
                .neckBack
            ]
        }
    }

    private func toggle(_ location: PainLocation) {
        if selectedLocations.contains(location) {
            selectedLocations.remove(location)
        } else {
            selectedLocations.insert(location)
        }
    }

    private func animateFlip(to newSide: DiagramBodySide) {
        guard !isFlipping else { return }
        isFlipping = true

        withAnimation(.easeIn(duration: 0.22)) {
            flipDegrees = 90
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            displayedSide = newSide
            flipDegrees = -90

            withAnimation(.easeOut(duration: 0.22)) {
                flipDegrees = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                isFlipping = false
            }
        }
    }

    private func zIndex(for location: PainLocation) -> Double {
        switch location {
        case .face:
            return 3
        case .neckFront, .neckBack:
            return 2
        case .headFront, .headBack:
            return 1
        default:
            return 0
        }
    }

    private func placement(for location: PainLocation) -> RegionPlacement {
        switch location {
        case .headFront:
            return RegionPlacement(
                origin: CGPoint(x: 75, y: 6),
                size: CGSize(width: 92, height: 97)
            )
        case .face:
            return RegionPlacement(
                origin: CGPoint(x: 95, y: 25),
                size: CGSize(width: 52, height: 65)
            )
        case .neckFront:
            return RegionPlacement(
                origin: CGPoint(x: 105, y: 100),
                size: CGSize(width: 32, height: 19)
            )
        case .chestLeft:
            return RegionPlacement(
                origin: CGPoint(x: 135, y: 110),
                size: CGSize(width: 62, height: 52)
            )
        case .chestCentre:
            return RegionPlacement(
                origin: CGPoint(x: 105, y: 110),
                size: CGSize(width: 32, height: 52)
            )
        case .chestRight:
            return RegionPlacement(
                origin: CGPoint(x: 45, y: 110),
                size: CGSize(width: 62, height: 52)
            )
        case .abdomenLeft:
            return RegionPlacement(
                origin: CGPoint(x: 135, y: 160),
                size: CGSize(width: 62, height: 57)
            )
        case .abdomenCentre:
            return RegionPlacement(
                origin: CGPoint(x: 105, y: 160),
                size: CGSize(width: 32, height: 57)
            )
        case .abdomenRight:
            return RegionPlacement(
                origin: CGPoint(x: 45, y: 160),
                size: CGSize(width: 62, height: 57)
            )
        case .pelvis:
            return RegionPlacement(
                origin: CGPoint(x: 60, y: 215),
                size: CGSize(width: 122, height: 37)
            )
        case .rightShoulderFront:
            return RegionPlacement(
                origin: CGPoint(x: 15, y: 119),
                size: CGSize(width: 47, height: 33)
            )
        case .rightUpperArmFront:
            return RegionPlacement(
                origin: CGPoint(x: 5, y: 135),
                size: CGSize(width: 42, height: 67)
            )
        case .rightForearmFront:
            return RegionPlacement(
                origin: CGPoint(x: 0, y: 195),
                size: CGSize(width: 32, height: 62)
            )
        case .rightHandFront:
            return RegionPlacement(
                origin: CGPoint(x: 0, y: 245),
                size: CGSize(width: 32, height: 29)
            )
        case .leftShoulderFront:
            return RegionPlacement(
                origin: CGPoint(x: 179, y: 119),
                size: CGSize(width: 47, height: 33)
            )
        case .leftUpperArmFront:
            return RegionPlacement(
                origin: CGPoint(x: 194, y: 135),
                size: CGSize(width: 42, height: 67)
            )
        case .leftForearmFront:
            return RegionPlacement(
                origin: CGPoint(x: 210, y: 195),
                size: CGSize(width: 32, height: 62)
            )
        case .leftHandFront:
            return RegionPlacement(
                origin: CGPoint(x: 210, y: 245),
                size: CGSize(width: 32, height: 29)
            )
        case .rightThighFront:
            return RegionPlacement(
                origin: CGPoint(x: 64, y: 223),
                size: CGSize(width: 47, height: 114)
            )
        case .rightKneeFront:
            return RegionPlacement(
                origin: CGPoint(x: 64, y: 335),
                size: CGSize(width: 47, height: 23)
            )
        case .rightShin:
            return RegionPlacement(
                origin: CGPoint(x: 64, y: 356),
                size: CGSize(width: 47, height: 81)
            )
        case .rightFootFront:
            return RegionPlacement(
                origin: CGPoint(x: 68, y: 435),
                size: CGSize(width: 43, height: 25)
            )
        case .leftThighFront:
            return RegionPlacement(
                origin: CGPoint(x: 129, y: 225),
                size: CGSize(width: 47, height: 112)
            )
        case .leftKneeFront:
            return RegionPlacement(
                origin: CGPoint(x: 129, y: 335),
                size: CGSize(width: 47, height: 22)
            )
        case .leftShin:
            return RegionPlacement(
                origin: CGPoint(x: 129, y: 355),
                size: CGSize(width: 47, height: 82)
            )
        case .leftFootFront:
            return RegionPlacement(
                origin: CGPoint(x: 129, y: 435),
                size: CGSize(width: 43, height: 25)
            )
        
        case .headBack:
            return RegionPlacement(
                origin: CGPoint(x: 75, y: 6),
                size: CGSize(width: 92, height: 97)
            )

        case .neckBack:
            return RegionPlacement(
                origin: CGPoint(x: 105, y: 100),
                size: CGSize(width: 32, height: 15)
            )

        case .upperBackLeft:
            return RegionPlacement(
                origin: CGPoint(x: 45, y: 110),
                size: CGSize(width: 62, height: 52)
            )

        case .upperBackCentre:
            return RegionPlacement(
                origin: CGPoint(x: 105, y: 110),
                size: CGSize(width: 32, height: 52)
            )

        case .upperBackRight:
            return RegionPlacement(
                origin: CGPoint(x: 135, y: 110),
                size: CGSize(width: 62, height: 52)
            )
        
        case .lowerBackLeft:
            return RegionPlacement(
                origin: CGPoint(x: 45, y: 160),
                size: CGSize(width: 62, height: 57)
            )

        case .lowerBackCentre:
            return RegionPlacement(
                origin: CGPoint(x: 105, y: 160),
                size: CGSize(width: 32, height: 57)
            )

        case .lowerBackRight:
            return RegionPlacement(
                origin: CGPoint(x: 135, y: 160),
                size: CGSize(width: 62, height: 57)
            )

        case .rightGlute:
            return RegionPlacement(
                origin: CGPoint(x: 120, y: 215),
                size: CGSize(width: 62, height: 37)
            )

        case .leftGlute:
            return RegionPlacement(
                origin: CGPoint(x: 60, y: 215),
                size: CGSize(width: 62, height: 37)
            )
        
        case .leftShoulderBack:
            return RegionPlacement(
                origin: CGPoint(x: 15, y: 119),
                size: CGSize(width: 47, height: 33)
            )

        case .leftUpperArmBack:
            return RegionPlacement(
                origin: CGPoint(x: 5, y: 135),
                size: CGSize(width: 42, height: 67)
            )

        case .leftForearmBack:
            return RegionPlacement(
                origin: CGPoint(x: 0, y: 195),
                size: CGSize(width: 32, height: 62)
            )

        case .leftHandBack:
            return RegionPlacement(
                origin: CGPoint(x: 0, y: 245),
                size: CGSize(width: 32, height: 29)
            )

        case .rightShoulderBack:
            return RegionPlacement(
                origin: CGPoint(x: 179, y: 119),
                size: CGSize(width: 47, height: 33)
            )

        case .rightUpperArmBack:
            return RegionPlacement(
                origin: CGPoint(x: 194, y: 135),
                size: CGSize(width: 42, height: 67)
            )

        case .rightForearmBack:
            return RegionPlacement(
                origin: CGPoint(x: 210, y: 195),
                size: CGSize(width: 32, height: 62)
            )

        case .rightHandBack:
            return RegionPlacement(
                origin: CGPoint(x: 210, y: 245),
                size: CGSize(width: 32, height: 29)
            )

        case .leftThighBack:
            return RegionPlacement(
                origin: CGPoint(x: 65, y: 224),
                size: CGSize(width: 47, height: 118)
            )

        case .leftCalf:
            return RegionPlacement(
                origin: CGPoint(x: 65, y: 340),
                size: CGSize(width: 47, height: 97)
            )

        case .leftHeel:
            return RegionPlacement(
                origin: CGPoint(x: 70, y: 435),
                size: CGSize(width: 42, height: 22)
            )

        case .rightThighBack:
            return RegionPlacement(
                origin: CGPoint(x: 129, y: 226),
                size: CGSize(width: 47, height: 119)
            )

        case .rightCalf:
            return RegionPlacement(
                origin: CGPoint(x: 129, y: 340),
                size: CGSize(width: 47, height: 97)
            )

        case .rightHeel:
            return RegionPlacement(
                origin: CGPoint(x: 129, y: 435),
                size: CGSize(width: 42, height: 22)
            )
        }
    }
}
