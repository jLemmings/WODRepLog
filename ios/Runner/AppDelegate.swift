import Flutter
import UIKit
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var audioEngine: AVAudioEngine?
  private var audioPlayer: AVAudioPlayerNode?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let beepChannel = FlutterMethodChannel(
      name: "ch.joshuahemmings.wodreplog/beep",
      binaryMessenger: controller.binaryMessenger
    )

    beepChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "playBeep":
        let args = call.arguments as? [String: Any]
        let durationMs = args?["durationMs"] as? Int ?? 180
        self?.playBeep(durationMs: durationMs)
        result(nil)
      case "stopBeep":
        self?.stopBeep()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func playBeep(durationMs: Int) {
    stopBeep()

    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    let frameCount = AVAudioFrameCount(format.sampleRate * Double(durationMs) / 1000.0)
    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
    buffer.frameLength = frameCount

    if let channel = buffer.floatChannelData?[0] {
      let frequency = 1_475.0
      let amplitude: Float = 0.35
      for frame in 0..<Int(frameCount) {
        let sampleTime = Double(frame) / format.sampleRate
        channel[frame] = sin(Float(2.0 * Double.pi * frequency * sampleTime)) * amplitude
      }
    }

    engine.attach(player)
    engine.connect(player, to: engine.mainMixerNode, format: format)

    do {
      try engine.start()
      player.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
        DispatchQueue.main.async {
          self?.stopBeep()
        }
      }
      player.play()
      audioEngine = engine
      audioPlayer = player
    } catch {
      stopBeep()
    }
  }

  private func stopBeep() {
    audioPlayer?.stop()
    audioEngine?.stop()
    audioPlayer = nil
    audioEngine = nil
  }
}
