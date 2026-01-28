//
//  SpeechRecognizer.swift
//  PainPal
//
//  Created by Chapman Leung on 18/1/2026.
//

import Foundation
import AVFoundation
import Speech
import Combine

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
///
/// NOTE: This is a @MainActor ObservableObject so SwiftUI reliably refreshes when `transcript` changes.
@MainActor
public final class SpeechRecognizer: ObservableObject {
    public enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable

        public var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }

    /// Live transcription text (updates while listening).
    @Published public var transcript: String = ""

    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?

    /// Initializes a new speech recognizer and triggers a permission preflight.
    /// If this is the first time you've used speech recognition, iOS will prompt the user.
    public init() {
        recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer)
            return
        }

        // Kick off a permission preflight so the user is prompted early.
        Task {
            _ = await SFSpeechRecognizer.hasAuthorizationToRecognize()
            _ = await AVAudioSession.sharedInstance().hasPermissionToRecord()
        }
    }

    /// Start listening and transcribing.
    public func startTranscribing() {
        Task { await start() }
    }

    /// Clear the current transcript.
    public func resetTranscript() {
        transcript = ""
    }

    /// Stop listening.
    public func stopTranscribing() {
        Task { await stop() }
    }

    /// Starts streaming speech-to-text. Checks permissions and sets up the audio engine + recognition task.
    private func start() async {
        // Re-check permissions on start (user may have changed Settings).
        do {
            guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                throw RecognizerError.notAuthorizedToRecognize
            }
            guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                throw RecognizerError.notPermittedToRecord
            }
        } catch {
            transcribe(error)
            return
        }

        guard let recognizer, recognizer.isAvailable else {
            transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }

        // Clean up any previous run.
        await stop()

        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request

            self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                // Ensure state updates happen on the main actor.
                Task { @MainActor in
                    self.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
                }
            }
        } catch {
            await stop()
            transcribe(error)
        }
    }

    /// Stops streaming and releases audio / recognition resources.
    private func stop() async {
        task?.cancel()
        task = nil

        // End the request so the recognizer can finish cleanly.
        request?.endAudio()
        request = nil

        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            engine.inputNode.removeTap(onBus: 0)
        }
        audioEngine = nil
    }

    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode

        // Defensive: ensure we don't install multiple taps on repeated starts.
        inputNode.removeTap(onBus: 0)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        return (audioEngine, request)
    }

    private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil

        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        if let result {
            transcript = result.bestTranscription.formattedString
        }

        if receivedFinalResult || receivedError {
            // Ensure our stored state is cleaned up.
            Task { await stop() }
        }
    }

    private func transcribe(_ message: String) {
        transcript = message
    }

    private func transcribe(_ error: Error) {
        let errorMessage: String
        if let error = error as? RecognizerError {
            errorMessage = error.message
        } else {
            errorMessage = error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
