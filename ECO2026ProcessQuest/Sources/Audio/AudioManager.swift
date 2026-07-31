import AVFoundation

/// Maneja los tres sonidos del juego con AVFoundation:
/// 1. `focus_loop.mp3`   — loop suave de concentración (opcional, modo ADHD).
/// 2. `success_chime.mp3`— celebración corta al acertar.
/// 3. `soft_error.mp3`   — feedback suave (no agresivo) al fallar.
///
/// Si los archivos no están en el bundle, se sintetizan tonos suaves con
/// AVAudioEngine para que la app funcione sin assets externos.
final class AudioManager {

    static let shared = AudioManager()

    /// Silencio global (botón de sonido del header).
    var isMuted = false

    private let engine = AVAudioEngine()
    private let fxPlayer = AVAudioPlayerNode()        // acierto / error
    private let ambientPlayer = AVAudioPlayerNode()   // loop de concentración

    private var bundledPlayers: [String: AVAudioPlayer] = [:]
    private var successBuffer: AVAudioPCMBuffer?
    private var errorBuffer: AVAudioPCMBuffer?
    private var focusBuffer: AVAudioPCMBuffer?

    private let sampleRate: Double = 44_100
    private var format: AVAudioFormat {
        AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    }

    private(set) var isFocusLoopPlaying = false

    private init() {
        configureSession()
        loadBundledSoundsIfAvailable()
        setupSynthEngine()
    }

    // MARK: - API pública

    func playSuccess() {
        guard !isMuted else { return }
        if let player = bundledPlayers["success_chime"] {
            player.currentTime = 0
            player.play()
        } else if let buffer = successBuffer {
            playSynth(buffer: buffer)
        }
    }

    func playSoftError() {
        guard !isMuted else { return }
        if let player = bundledPlayers["soft_error"] {
            player.currentTime = 0
            player.play()
        } else if let buffer = errorBuffer {
            playSynth(buffer: buffer)
        }
    }

    /// Activa/desactiva el loop de concentración (ambient suave).
    func setFocusLoop(enabled: Bool) {
        if enabled && !isMuted {
            startFocusLoop()
        } else {
            stopFocusLoop()
        }
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        if muted { stopFocusLoop() }
    }

    // MARK: - Sesión y carga de assets

    private func configureSession() {
        // .ambient: se mezcla con otras apps y respeta el interruptor de silencio.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func loadBundledSoundsIfAvailable() {
        // Placeholders esperados en el bundle: focus_loop.mp3, success_chime.mp3, soft_error.mp3
        for name in ["focus_loop", "success_chime", "soft_error"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "mp3"),
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                if name == "focus_loop" {
                    player.numberOfLoops = -1
                    player.volume = 0.35
                }
                bundledPlayers[name] = player
            }
        }
    }

    // MARK: - Síntesis de respaldo (sin archivos externos)

    private func setupSynthEngine() {
        engine.attach(fxPlayer)
        engine.attach(ambientPlayer)
        engine.connect(fxPlayer, to: engine.mainMixerNode, format: format)
        engine.connect(ambientPlayer, to: engine.mainMixerNode, format: format)

        successBuffer = makeBuffer(duration: 0.45) { t, progress in
            // Campanita de dos notas ascendentes con decaimiento exponencial.
            let freq: Double = progress < 0.4 ? 659.25 : 987.77   // E5 -> B5
            let envelope = exp(-4.5 * progress)
            return Float(sin(2 * .pi * freq * t) * 0.35 * envelope)
        }

        errorBuffer = makeBuffer(duration: 0.35) { t, progress in
            // Tono grave, suave y corto: feedback amable, no castigo.
            let attack = min(1.0, progress * 8)
            let release = exp(-5.0 * progress)
            return Float(sin(2 * .pi * 196.0 * t) * 0.22 * attack * release)
        }

        focusBuffer = makeBuffer(duration: 6.0) { t, _ in
            // Pad suave: dos senos graves ligeramente desafinados + oleaje lento.
            let swell = 0.5 + 0.5 * sin(2 * .pi * 0.15 * t)
            let tone = sin(2 * .pi * 110.0 * t) + sin(2 * .pi * 110.7 * t)
            return Float(tone * 0.05 * swell)
        }
    }

    private func makeBuffer(duration: Double,
                            render: (_ t: Double, _ progress: Double) -> Float) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return nil }
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            channel[frame] = render(t, t / duration)
        }
        return buffer
    }

    private func ensureEngineRunning() -> Bool {
        if engine.isRunning { return true }
        do {
            try engine.start()
            return true
        } catch {
            return false
        }
    }

    private func playSynth(buffer: AVAudioPCMBuffer) {
        guard ensureEngineRunning() else { return }
        fxPlayer.stop()
        fxPlayer.scheduleBuffer(buffer, at: nil, options: .interrupts)
        fxPlayer.play()
    }

    private func startFocusLoop() {
        guard !isFocusLoopPlaying else { return }
        if let player = bundledPlayers["focus_loop"] {
            player.play()
            isFocusLoopPlaying = true
        } else if let buffer = focusBuffer, ensureEngineRunning() {
            ambientPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
            ambientPlayer.play()
            isFocusLoopPlaying = true
        }
    }

    private func stopFocusLoop() {
        guard isFocusLoopPlaying else { return }
        bundledPlayers["focus_loop"]?.pause()
        ambientPlayer.stop()
        isFocusLoopPlaying = false
    }
}
