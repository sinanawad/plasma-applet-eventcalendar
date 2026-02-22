// Version 3

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

CheckBox {
	id: configCheckBox

	property string configKey: ''
	checked: plasmoid.configuration[configKey]
	onClicked: plasmoid.configuration[configKey] = checked
}
