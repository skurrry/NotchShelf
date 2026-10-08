import AppKit

@MainActor
final class AlarmSoundService {
    private var sound: NSSound?

    func startLooping() {
        stop()

        let choice = AlarmPreferences.sound

        guard
            let url = Bundle.main.url(
                forResource: choice.rawValue,
                withExtension: "aiff"
            ),
            let sound = NSSound(
                contentsOf: url,
                byReference: false
            )
        else {
            NSSound.beep()
            return
        }

        sound.loops = true
        self.sound = sound
        sound.play()
    }

    func preview(
        choice: AlarmSoundChoice
    ) {
        stop()

        guard
            let url = Bundle.main.url(
                forResource: choice.rawValue,
                withExtension: "aiff"
            ),
            let sound = NSSound(
                contentsOf: url,
                byReference: false
            )
        else {
            NSSound.beep()
            return
        }

        sound.loops = false
        self.sound = sound
        sound.play()
    }

    func stop() {
        sound?.stop()
        sound = nil
    }
}
