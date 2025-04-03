// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


/**
 Structures and classes have a similar definition syntax. Whenever you define a new structure or class, you define a new Swift type.
 
 Structures are value types, whereas classes are reference types.
  - A value type is a type whose value is copied when it’s assigned to a variable or constant, or when it’s passed to a function.
  - Reference types are not copied when they’re assigned to a variable or constant, or when they’re passed to a function. A reference to the same existing instance is used instead.
 
 Default initializer are available for any structure or class that provides default values for all of its properties. Structures have an automatically generated memberwise initializer.
 
 Use 'self.*' for ambiguous names.
 
 Note, strings are value types.
 
 === (identity operator), == (equal operator)
 
 Use UpperCamelCase.
 
 Excluded
  - access control, open, public, etc.
 */
func workingWithInstances() {
    introduce(topic: "Instances")
   
    // local structs and classes are no problem
    struct Resolution {
        var width = 0
        var height = 0
    }

    class VideoMode {
        var resolution = Resolution()
        var interlaced = false
        var frameRate = 0.0
        var name: String?
    }

    // create some instances
    var res1 = Resolution()
    let res2 = Resolution(width: 100, height: 200)
    let res3 = res1
    print(" 1| res1=\(res1), res2=\(res2), res3=\(res3)")
    
    // what happens with res3?
    res1.width = 10
    res1.height = 20
    print(" 2| res1=\(res1), res2=\(res2), res3=\(res3)")
    
    // same with a class, i.e. a reference type
    let vm1 = VideoMode()
    let vm2 = VideoMode()
    let vm3 = vm1
    print(" 3| vm1=\(vm1), ..., ")
    
    // what happens here?
    vm1.frameRate = 24
    vm2.frameRate = 25
    vm3.frameRate = 30
    print(" 4| vm1.frameRate=\(vm1.frameRate), vm2.frameRate=\(vm2.frameRate), vm3.frameRate=\(vm3.frameRate) ")
    
    // identical, i.e. referencing the same object? (not the same as equal (==))
    let identical12 = vm1===vm2
    let identical13 = vm1===vm3
    print(" 5| identical12=\(identical12), identical13=\(identical13)")
}


//----------------------


/// struct holds a temperature and can be initialized from different sources
struct Celsius: CustomStringConvertible {
    var temperatureInCelsius: Double = 0.0
    
    // default
    init() { }
    
    init(fromFahrenheit fahrenheit: Double) {
        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
    }
    
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }
    
    // initializer delegation; note, 'init' is needed in all paths;
    // (technical: if any branch delegates with self.init(...), then all code paths must delegate, and you cannot assign properties manually)
    init(fromText text: String) {
        switch text.suffix(1) {
        case "F":
            self.init(fromFahrenheit: Double(text.dropLast())!)
        case "K":
            self.init(fromKelvin: Double(text.dropLast())!)
        case "C":
            self.init()
            temperatureInCelsius = Double(text.dropLast())!
        default:
            self.init()
            temperatureInCelsius = Double(text)!
        }
    }
    
    // from CustomStringConvertible protocol
    var description: String {
        return "\(temperatureInCelsius)C"
    }
}

/**
 Init instances in many ways.
 
 Mutating a const
  - from the outside: Okay to mutate if the instance is a var
  - from the inside (method): Must use 'mutating' to tell Swift you’re changing self (which is 'let' by default)
 
 Excluded
  - deinit
  - no property observer called
  - failable
 */
func initInstances() {
    introduce(topic: "Init")
        
    let boilingPointOfWater = Celsius(fromFahrenheit: 212.0)
    let freezingPointOfWater = Celsius(fromKelvin: 273.15)
    print(" 1| boiling=\(boilingPointOfWater.temperatureInCelsius)")
    print(" 2| freezing=\(freezingPointOfWater.temperatureInCelsius)")
    
    let T1 = Celsius(fromText: "212F")
    let T2 = Celsius(fromText: "373.15K")
    let T3 = Celsius(fromText: "100C")
    let T4 = Celsius(fromText: "100")
    // here, string representation is used
    print(" 3| T1=\(T1), T2=\(T2), T3=\(T3), T4=\(T4)")
}


//----------------------


/// struct models a distance with an origin and a fixed length, end is computed
struct Distance {
    var origin: Int                         // stored
    let length: Int
    
    var end: Int {                          // computed; set is optional, read-only computed property otherwise
        //  get { return origin + length }
        //  set(newEnd) { origin = newEnd - length  }
        get { origin + length }             // short-hand getter
        set { origin = newValue - length }  // short-hand setter; 'newValue' is default name
    }
    
    // instance method; 'mutating' is needed as it is a value type
    mutating func adjust(center: Int) {
        origin = center - Int(Double(length) / 2.0)
    }
}

/// struct with an 'observed' value
struct ObervedValues {
    var n: Int = 99 {
        willSet { print(" a|   will set n, n=\(n), new=\(newValue)") }
        didSet { print(" b|   did set n, old=\(oldValue), n=\(n)") }
    }
    
    lazy var m: Int = { print(" c|   lazy m initialized"); return 1000 }()
}

/**
 Works with properties.
 
 Note, for a stored property a getter and setter is created such that we later can 'override', or wrap, the access.
 
 Excluded
  - assigning to self
  - static methods and properties, class methods
  - subscripts
 */
func usingProperties() {
    introduce(topic: "Properties")
    
    var range3 = Distance(origin: 0, length: 3)
    range3.origin = 2
    print(" 1| range3=\(range3), end=\(range3.end)")
    
    range3.end = 10
    print(" 2| range3=\(range3), end=\(range3.end)")

    let range5 = Distance(origin: 0, length: 5)
    // range5.origin = 2                    // const, even if stored property is var
    print(" 3| range5=\(range5), end=\(range5.end)")
        
    var range6 = Distance(origin: 10, length: 6)
    range6.adjust(center: 0)
    print(" 4| range6=\(range6), end=\(range6.end)")

    var obs = ObervedValues(n: 5)
    print(" 5| obs.n=\(obs.n)")
    obs.n = 10
    print(" 6| obs.n=\(obs.n)")
    
    print(" 7| obs.m=\(obs.m)")
}


//----------------------


enum Player {
    case x
    case o

    var symbol: String {
        switch self {
        case .x: return "X"
        case .o: return "O"
        }
    }
}

enum StringPlayer: String {
    case x = "❌"
    case o = "⭕"
    case none = ""
}


// an enum with associated values and computed properties, just to flex a bit:
enum NetworkResponse: CustomStringConvertible {
    case success
    case failure(error: String)
    case empty
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var description: String {
        switch self {
        case .success:
            return "✅ Success"
        case .failure(let error):
            return "❌ Error: \(error)"
        case .empty:
            return "📭 No data"
        }
    }
}

func usingEnums() {
    introduce(topic: "Enums")
    
    let player: Player = .o                                     // or Player.o
    print(" 1| player.symbol=\(player.symbol)")                 // no rawValue
    
    let stringPlayer: StringPlayer = .x
    print(" 2| stringPlayer.rawValue=\(stringPlayer.rawValue)") // here we have a string
    
    let responseOk: NetworkResponse = .success
    let responseFail: NetworkResponse = .failure(error: "Network timeout")
    print(" 3| responses: ok=\(responseOk), \(responseFail)")   // without obj.description
}


//----------------------


workingWithInstances()
initInstances()
usingProperties()
usingEnums()


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
