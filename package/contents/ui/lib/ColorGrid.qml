import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GroupBox {
	id: colorGrid
	Layout.fillWidth: true
	default property alias _contentChildren: content.data

	contentItem: GridLayout {
		id: content
		columns: 2

		Component.onCompleted: {
			for (var i = 0; i < children.length; i++) {
				var child = children[i]
				if (typeof child.configKey !== "undefined") {
					child.horizontalAlignment = Text.AlignRight
				}
			}
		}
	}
}
