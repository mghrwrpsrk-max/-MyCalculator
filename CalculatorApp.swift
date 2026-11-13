import SwiftUI
import UIKit

@main
struct GlassCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

enum CalcButton: String {
    case one = "1", two = "2", three = "3", four = "4", five = "5"
    case six = "6", seven = "7", eight = "8", nine = "9", zero = "0"
    case add = "+", subtract = "−", multiply = "×", divide = "÷"
    case equal = "=", clear = "AC", decimal = ".", percent = "%", negative = "+/-"

    var buttonColor: [Color] {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return [Color(red: 0.45, green: 0.15, blue: 0.95), Color(red: 0.1, green: 0.55, blue: 1.0)]
        case .clear, .negative, .percent:
            return [Color.white.opacity(0.22), Color.white.opacity(0.08)]
        default:
            return [Color.white.opacity(0.12), Color.white.opacity(0.03)]
        }
    }
    
    var glowColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return Color(red: 0.3, green: 0.4, blue: 1.0).opacity(0.55)
        default:
            return Color.black.opacity(0.45)
        }
    }
}

enum Operation {
    case add, subtract, multiply, divide, none
}

struct ContentView: View {
    @State private var value = "0"
    @State private var history = ""
    @State private var runningNumber = 0.0
    @State private var currentOperation: Operation = .none
    @State private var isTypingNumber = false

    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]

    var body: some View {
        ZStack {
            // پس‌زمینه دارک با گوی‌های نئونی برای ایجاد عمق شیشه‌ای
            Color(red: 0.04, green: 0.04, blue: 0.09).ignoresSafeArea()
            
            Circle()
                .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 280, height: 280)
                .blur(radius: 75)
                .offset(x: -110, y: -220)
            
            Circle()
                .fill(LinearGradient(colors: [.cyan, .indigo], startPoint: .top, endPoint: .bottom))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 120, y: 180)

            VStack(spacing: 16) {
                Spacer()
                
                // پنل نمایشگر شیشه‌ای سه‌بعدی
                VStack(alignment: .trailing, spacing: 8) {
                    Text(history)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(height: 26)
                    
                    Text(value)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .shadow(color: .cyan.opacity(0.35), radius: 12, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 26)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.45), .white.opacity(0.05), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 12)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                // شبکه دکمه‌های سه‌بعدی
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 14) {
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                self.didTap(button: item)
                            }) {
                                Text(item.rawValue)
                                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(
                                        width: self.buttonWidth(item: item),
                                        height: self.buttonHeight()
                                    )
                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .fill(.ultraThinMaterial)
                                            
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: item.buttonColor,
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                            
                                            // خط نورانی لبه بالایی برای حس برجستگی سه‌بعدی
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.5), .clear, .white.opacity(0.1)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.2
                                                )
                                        }
                                    )
                                    .shadow(color: item.glowColor, radius: 10, x: 0, y: 8)
                            }
                            .buttonStyle(ThreeDPressStyle())
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }

    func didTap(button: CalcButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        switch button {
        case .add, .subtract, .multiply, .divide, .equal:
            if button == .add {
                currentOperation = .add
                runningNumber = Double(value) ?? 0
                history = "\(formatResult(runningNumber)) +"
            } else if button == .subtract {
                currentOperation = .subtract
                runningNumber = Double(value) ?? 0
                history = "\(formatResult(runningNumber)) −"
            } else if button == .multiply {
                currentOperation = .multiply
                runningNumber = Double(value) ?? 0
                history = "\(formatResult(runningNumber)) ×"
            } else if button == .divide {
                currentOperation = .divide
                runningNumber = Double(value) ?? 0
                history = "\(formatResult(runningNumber)) ÷"
            } else if button == .equal {
                let currentValue = Double(value) ?? 0
                var result = currentValue
                switch currentOperation {
                case .add: result = runningNumber + currentValue
                case .subtract: result = runningNumber - currentValue
                case .multiply: result = runningNumber * currentValue
                case .divide: result = currentValue != 0 ? runningNumber / currentValue : 0
                case .none: break
                }
                history = ""
                value = formatResult(result)
                currentOperation = .none
            }
            isTypingNumber = false

        case .clear:
            value = "0"
            history = ""
            runningNumber = 0
            currentOperation = .none
            isTypingNumber = false

        case .decimal:
            if !value.contains(".") {
                value += "."
                isTypingNumber = true
            }

        case .negative:
            if let val = Double(value) {
                value = formatResult(val * -1)
            }

        case .percent:
            if let val = Double(value) {
                value = formatResult(val / 100)
            }

        default:
            let number = button.rawValue
            if isTypingNumber {
                if value.count < 11 {
                    value = "\(value)\(number)"
                }
            } else {
                value = number
                isTypingNumber = true
            }
        }
    }

    func formatResult(_ val: Double) -> String {
        if val.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", val)
        } else {
            return String(format: "%.6g", val)
        }
    }

    func buttonWidth(item: CalcButton) -> CGFloat {
        let spacing: CGFloat = 14
        let totalSpacing: CGFloat = 5 * spacing
        let screenWidth = UIScreen.main.bounds.width
        let standardWidth = (screenWidth - totalSpacing) / 4
        if item == .zero {
            return standardWidth * 2 + spacing
        }
        return standardWidth
    }

    func buttonHeight() -> CGFloat {
        let spacing: CGFloat = 14
        let totalSpacing: CGFloat = 5 * spacing
        return (UIScreen.main.bounds.width - totalSpacing) / 4
    }
}

// انیمیشن فرو رفتن فیزیکی دکمه در حالت سه‌بعدی
struct ThreeDPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .offset(y: configuration.isPressed ? 4 : 0)
            .brightness(configuration.isPressed ? 0.08 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
