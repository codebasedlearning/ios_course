// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import CoreMotion

@Observable
class SensorModel {
    private var motionManager = CMMotionManager()
    
    var accelerometerData: CMAccelerometerData?  // @ObservationTracked
    var gyroData: CMGyroData?
    
    func startReadingSensors() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let data = data {
                    self?.accelerometerData = data
                }
            }
        }
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let data = data {
                    self?.gyroData = data
                }
            }
        }
    }
    
    func stopReadingSensors() {
        if motionManager.isAccelerometerAvailable {
            motionManager.stopAccelerometerUpdates()
        }
        if motionManager.isGyroAvailable {
            motionManager.stopGyroUpdates()
        }
    }
}

/*
 
 From GPT
 
 Accelerometer
 =============
 
 Function: Measures linear acceleration of movement.
 Axes: Typically measures along three axes (x, y, z).
 Units: Acceleration is measured in meters per second squared (m/s²) or G-force (g).

 Purpose:

 Orientation: Detects the orientation of the device relative to the Earth's gravity. For example, it can tell if the device is lying flat, standing up, or upside down.
 Motion Detection: Tracks movements such as tilting, shaking, or free-fall events.
 Step Counting: Commonly used in fitness trackers to count steps by detecting the motion of walking or running.
 How It Works: Uses capacitive sensing, piezoelectric effects, or MEMS technology to detect changes in acceleration.

 Applications:

 Screen rotation (portrait to landscape)
 Step counters
 Gaming controls (detecting tilts and shakes)
 Vibration monitoring
 
 
 Gyroscope
 =========
 
 Function: Measures the rate of rotation around an axis.
 Axes: Also typically measures along three axes (x, y, z).
 Units: Angular velocity is measured in degrees per second (°/s) or radians per second (rad/s).

 Purpose:

 Rotation Detection: Measures how fast and in what direction the device is rotating.
 Orientation and Stabilization: Provides more detailed orientation data, especially useful for tracking complex movements.
 Augmented Reality: Enhances AR applications by providing precise rotational information.
 How It Works: Uses MEMS technology to detect the Coriolis effect, which occurs when a mass inside the sensor is subjected to rotational forces.

 Applications:

 Enhanced gaming experiences (detecting precise movements and orientation)
 Camera stabilization (to counteract hand shake)
 Augmented reality (providing accurate orientation data)
 Navigation systems (improving accuracy of motion detection)
 
 
 
 Key Differences
 
 Type of Measurement:

 Accelerometer: Measures linear acceleration along the x, y, and z axes.
 Gyroscope: Measures rotational velocity around the x, y, and z axes.
 Primary Use:

 Accelerometer: Used for detecting orientation and linear movement.
 Gyroscope: Used for detecting rotation and providing precise orientation.
 Output Data:

 Accelerometer: Provides data on how much the device's position changes in space.
 Gyroscope: Provides data on how fast the device is rotating.
 Combined Use
 In many devices, both sensors are used together to provide a complete picture of the device's motion and orientation. This combination, often referred to as an IMU (Inertial Measurement Unit), is crucial for applications like:

 Smartphone orientation and motion sensing: For better accuracy in detecting tilts, shakes, and rotations.
 Virtual Reality (VR) and Augmented Reality (AR): To track head and body movements more accurately.
 Advanced navigation systems: For dead reckoning and other sophisticated tracking methods.

 */
