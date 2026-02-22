// Version 4

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
	id: configSpinBox

	property string configKey: ''
	readonly property var configValue: configKey ? plasmoid.configuration[configKey] : 0
	property int decimals: 0
	property int horizontalAlignment: Qt.AlignLeft
	property alias maximumValue: spinBox.to
	property alias minimumValue: spinBox.from
	property string prefix: ""
	property alias stepSize: spinBox.stepSize
	property string suffix: ""
	property alias value: spinBox.value

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	Label {
		id: labelBefore
		text: ""
		visible: text
	}

	SpinBox {
		id: spinBox

		value: configSpinBox.configValue
		onValueModified: serializeTimer.start()
		to: 2147483647

		textFromValue: function(value, locale) {
			return configSpinBox.prefix + value + configSpinBox.suffix
		}
		valueFromText: function(text, locale) {
			var s = text
			if (configSpinBox.prefix) s = s.replace(configSpinBox.prefix, "")
			if (configSpinBox.suffix) s = s.replace(configSpinBox.suffix, "")
			return parseInt(s) || 0
		}
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: {
			if (configKey) {
				plasmoid.configuration[configKey] = value
			}
		}
	}
}
