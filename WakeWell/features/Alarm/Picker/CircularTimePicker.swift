import UIKit

enum SelectedHandle {
    case none, bed, sun
}

@IBDesignable
class CircularTimePicker: UIControl {

    // MARK: - Public

    var bedtime: Date { angleToDate(startAngle) }
    var wakeUp:  Date { angleToDate(endAngle) }

    var startAngle: CGFloat = CGFloat.pi
    var endAngle:   CGFloat = 0

    // MARK: - Layout
    private var ringCenter: CGPoint = .zero
    private var ringRadius: CGFloat = 0
    private let ringInset: CGFloat = 26

    // MARK: - Layers
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    // MARK: - Handles (🌙 ☀️)
    private let bedHandleView = UIImageView()
    private let sunHandleView = UIImageView()

    // MARK: - Header UI
    private var bedStack = UIStackView()
    private var wakeStack = UIStackView()

    private let bedCapLabel = UILabel()
    private let bedTimeLabel = UILabel()
    private let bedNightLabel = UILabel()

    private let wakeCapLabel = UILabel()
    private let wakeTimeLabel = UILabel()
    private let wakeDayLabel = UILabel()

    // MARK: - Labels
    private let durationLabel = UILabel()
    private var clockLabels: [UILabel] = []

    // MARK: - State
    private var selectedHandle: SelectedHandle = .none

    // MARK: - Constants
    private let trackWidth: CGFloat = 42
    private let handleSize: CGFloat = 44
    private let headerHeight: CGFloat = 90

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = WakeWellTheme.cardElevated
        layer.cornerRadius = 20
        clipsToBounds = false

        setupTrack()
        setupProgress()
        setupHandles()
        setupHeader()
        setupLabels()

        addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        )
    }

    // MARK: - Setup

    private func setupTrack() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = WakeWellTheme.border.cgColor
        trackLayer.lineWidth = trackWidth
        layer.addSublayer(trackLayer)
    }

    private func setupProgress() {
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = WakeWellTheme.accentGold.cgColor
        progressLayer.lineWidth = trackWidth
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
    }

    private func setupHandles() {

        
        bedHandleView.image = UIImage(systemName: "moon.fill")
        bedHandleView.tintColor = .white
        bedHandleView.backgroundColor = WakeWellTheme.accentPurple
        bedHandleView.layer.cornerRadius = handleSize / 2
        bedHandleView.contentMode = .center
        bedHandleView.frame.size = CGSize(width: handleSize, height: handleSize)

       
        sunHandleView.image = UIImage(systemName: "sun.max.fill")
        sunHandleView.tintColor = .white
        sunHandleView.backgroundColor = WakeWellTheme.accentGold
        sunHandleView.layer.cornerRadius = handleSize / 2
        sunHandleView.contentMode = .center
        sunHandleView.frame.size = CGSize(width: handleSize, height: handleSize)

        [bedHandleView, sunHandleView].forEach {
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowRadius = 4
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        }

        addSubview(bedHandleView)
        addSubview(sunHandleView)
    }

    private func setupHeader() {

        func makeStack() -> UIStackView {
            let s = UIStackView()
            s.axis = .vertical
            s.alignment = .center
            s.spacing = 2
            s.translatesAutoresizingMaskIntoConstraints = false
            return s
        }

        bedCapLabel.text = "Bed Time"
        wakeCapLabel.text = "Wake-up Time"

        [bedCapLabel, wakeCapLabel].forEach {
            $0.font = .systemFont(ofSize: 13)
            $0.textColor = WakeWellTheme.labelSecondary
        }

        [bedTimeLabel, wakeTimeLabel].forEach {
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.textColor = WakeWellTheme.labelPrimary
        }

        bedNightLabel.text = "Tonight"
        wakeDayLabel.text = "Tomorrow"

        [bedNightLabel, wakeDayLabel].forEach {
            $0.font = .systemFont(ofSize: 13)
            $0.textColor = WakeWellTheme.labelSecondary
        }

        bedStack = makeStack()
        wakeStack = makeStack()

        bedStack.addArrangedSubview(bedCapLabel)
        bedStack.addArrangedSubview(bedTimeLabel)
        bedStack.addArrangedSubview(bedNightLabel)

        wakeStack.addArrangedSubview(wakeCapLabel)
        wakeStack.addArrangedSubview(wakeTimeLabel)
        wakeStack.addArrangedSubview(wakeDayLabel)

        addSubview(bedStack)
        addSubview(wakeStack)

        NSLayoutConstraint.activate([
            bedStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bedStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            wakeStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            wakeStack.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        ])
    }

    private func setupLabels() {
        durationLabel.font = .systemFont(ofSize: 18, weight: .bold)
        durationLabel.textAlignment = .center
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(durationLabel)

        NSLayoutConstraint.activate([
            durationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            durationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        let texts = ["12PM","3PM","6PM","9PM","12AM","3AM","6AM","9AM"]

        clockLabels = texts.map {
            let l = UILabel()
            l.text = $0
            l.font = .systemFont(ofSize: 11, weight: .semibold)
            l.textColor = WakeWellTheme.labelSecondary
            l.sizeToFit()
            addSubview(l)
            return l
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let topPadding: CGFloat = 70   // space for header
        let bottomPadding: CGFloat = 50

        let usableHeight = bounds.height - topPadding - bottomPadding

        let diameter = min(bounds.width - 40, usableHeight)

        ringRadius = diameter / 2 - ringInset

        // ✅ FIXED CENTER
        ringCenter = CGPoint(
            x: bounds.midX,
            y: topPadding + usableHeight / 2 - 10   // slight upward shift
        )

        let path = UIBezierPath(
            arcCenter: ringCenter,
            radius: ringRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )

        trackLayer.path = path.cgPath

        updateArc()
        repositionLabels()
    }

    // MARK: - Arc

    private func updateArc() {
        let path = UIBezierPath(
            arcCenter: ringCenter,
            radius: ringRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        progressLayer.path = path.cgPath

        positionHandle(bedHandleView, angle: startAngle)
        positionHandle(sunHandleView, angle: endAngle)

        refreshLabels()
        durationLabel.text = durationString()
    }

    private func positionHandle(_ view: UIView, angle: CGFloat) {
        let pt = pointOnRing(angle: angle)
        view.center = pt
    }

    // MARK: - Labels

    private func repositionLabels() {
        let labelR = ringRadius - ringInset - 22

        for (i, label) in clockLabels.enumerated() {
            let angle = (-.pi / 2) + CGFloat(i) * (.pi / 4)
            label.center = CGPoint(
                x: ringCenter.x + labelR * cos(angle),
                y: ringCenter.y + labelR * sin(angle)
            )
        }
    }

    func refreshLabels() {
        bedTimeLabel.text = formatTime(bedtime)
        wakeTimeLabel.text = formatTime(wakeUp)
    }

    private func durationString() -> String {
        let diff = Calendar.current.dateComponents([.hour, .minute], from: bedtime, to: wakeUp)

        var h = diff.hour ?? 0
        var m = diff.minute ?? 0

        if h < 0 || (h == 0 && m < 0) { h += 24 }
        if m < 0 { m += 60; h -= 1 }

        return m == 0 ? "\(h) hr" : "\(h) hr \(m) min"
    }

    // MARK: - Gesture

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let loc = gesture.location(in: self)
        let angle = atan2(loc.y - ringCenter.y, loc.x - ringCenter.x)

        if gesture.state == .began {
            let bd = distance(loc, bedHandleView.center)
            let sd = distance(loc, sunHandleView.center)

            if bd < sd && bd < 44 { selectedHandle = .bed }
            else if sd < bd && sd < 44 { selectedHandle = .sun }
            else { selectedHandle = .none }
        }

        if gesture.state == .changed {
            if selectedHandle == .bed { startAngle = angle }
            else if selectedHandle == .sun { endAngle = angle }

            updateArc()
            sendActions(for: .valueChanged)
        }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    // MARK: - Math

    private func pointOnRing(angle: CGFloat) -> CGPoint {
        CGPoint(
            x: ringCenter.x + ringRadius * cos(angle),
            y: ringCenter.y + ringRadius * sin(angle)
        )
    }

    private func angleToDate(_ angle: CGFloat) -> Date {
        var n = angle + .pi / 2
        if n < 0 { n += 2 * .pi }
        if n > 2 * .pi { n -= 2 * .pi }

        let minutes = (n / (2 * .pi)) * (24 * 60)

        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 0
        c.minute = Int(minutes)

        return Calendar.current.date(from: c) ?? Date()
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}
