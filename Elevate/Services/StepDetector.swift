import Foundation

struct StepDetector {
    private var samples: [Double] = []
    private var lastStepTime: Date = .distantPast
    let threshold: Double
    let debounceInterval: TimeInterval
    let windowSize: Int

    init(threshold: Double = 0.3, debounceInterval: TimeInterval = 0.3, windowSize: Int = 5) {
        self.threshold = threshold
        self.debounceInterval = debounceInterval
        self.windowSize = windowSize
    }

    /// Returns true if a step was detected.
    mutating func processSample(_ verticalAcceleration: Double, at time: Date) -> Bool {
        samples.append(verticalAcceleration)
        if samples.count > windowSize { samples.removeFirst() }
        guard samples.count == windowSize else { return false }
        guard time.timeIntervalSince(lastStepTime) >= debounceInterval else { return false }

        let peak = samples.max()!
        let baseline = samples.min()!
        guard peak - baseline > threshold else { return false }

        lastStepTime = time
        samples.removeAll()
        return true
    }
}
