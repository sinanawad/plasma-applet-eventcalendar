// Version 6

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/*
** Example:
**
ConfigComboBox {
	configKey: "appDescription"
	model: [
		{ value: "a", text: i18n("A") },
		{ value: "b", text: i18n("B") },
		{ value: "c", text: i18n("C") },
	]
}
ConfigComboBox {
	configKey: "appDescription"
	populated: false
	onPopulate: {
		model = [
			{ value: "a", text: i18n("A") },
			{ value: "b", text: i18n("B") },
			{ value: "c", text: i18n("C") },
		]
	}
}
*/
RowLayout {
	id: configComboBox

	property string configKey: ''
	readonly property var currentItem: comboBox.model[comboBox.currentIndex]
	readonly property string value: comboBox.currentValue !== undefined ? String(comboBox.currentValue) : ""
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: {
		if (!comboBox.focus && value != configValue) {
			selectValue(configValue)
		}
	}

	property alias textRole: comboBox.textRole
	property alias valueRole: comboBox.valueRole
	property alias model: comboBox.model

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	signal populate()
	property bool populated: true

	Component.onCompleted: {
		populate()
		selectValue(configValue)
	}

	Label {
		id: labelBefore
		text: ""
		visible: text
	}

	ComboBox {
		id: comboBox
		textRole: "text"
		valueRole: "value"

		model: []

		onActivated: {
			if (configKey && populated) {
				var val = currentValue
				if (typeof val !== "undefined") {
					plasmoid.configuration[configKey] = val
				}
			}
		}
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	function size() {
		if (typeof model === "number") {
			return model
		} else if (typeof model.count === "number") {
			return model.count
		} else if (typeof model.length === "number") {
			return model.length
		} else {
			return 0
		}
	}

	function findValue(val) {
		for (var i = 0; i < size(); i++) {
			if (model[i][comboBox.valueRole] == val) {
				return i
			}
		}
		return -1
	}

	function selectValue(val) {
		var index = findValue(val)
		if (index >= 0) {
			comboBox.currentIndex = index
		}
	}
}
