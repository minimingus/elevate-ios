import CoreMotion
import Combine
import Foundation

@MainActor
final class SensorPipeline: ObservableObject {
    @Published private(set) var steps: Int = 0
    @Published private(set) var floors: Int = 0
    @Published private(set) var isClimbing: Bool = false

    private let motionManager = CMMotionManager()
    private let altimeter = CMAltimeter()
    private let pedometer = CMPedometer()
    private var stepDetector = StepDetector()
    private var lastRelativeAltitude: Double? = nil
    private let operationQueue = OperationQueue()
    private var sessionStart: Date?

    func start() {
        steps = 0
        floors = 0
        isClimbing = false
        lastRelativeAltitude = nil
        sessionStart = Date()
        stepDetector = StepDetector()

        startAltimeter()
        startAccelerometer()
        startPedometer()
    }

    /// Stops all sensors and returns the final (steps, floors) counts.
    func stop() -> (steps: Int, floors: Int) {
        motionManager.stopAccelerometerUpdates()
        altimeter.stopRelativeAltitudeUpdates()
        pedometer.stopUpdates()
        return (steps, floors)
    }

    // MARK: - Private

    private func startAltimeter() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
        altimeter.startRelativeAltitudeUpdates(to: operationQueue) { [weak self] data, _ in
            guard let self, let data else { return }
            let altitude = data.relativeAltitude.doubleValue
            Task { @MainActor in
                if let last = self.lastRelativeAltitude {
                    self.isClimbing = altitude > last
                }
                self.lastRelativeAltitude = altitude
            }
        }
    }

    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0
        motionManager.startAccelerometerUpdates(to: operationQueue) { [weak self] data, _ in
            guard let self, let data else { return }
            let z = data.acceleration.z
            let now = Date()
            Task { @MainActor in
                guard self.isClimbing else { return }
                if self.stepDetector.processSample(z, at: now) {
                    self.steps += 1
                }
            }
        }
    }

    private func startPedometer() {
        guard CMPedometer.isFloorCountingAvailable(), let start = sessionStart else { return }
        pedometer.startUpdates(from: start) { [weak self] data, _ in
            guard let self, let data else { return }
            Task { @MainActor in
                self.floors = data.floorsAscended?.intValue ?? 0
            }
        }
    }
}
