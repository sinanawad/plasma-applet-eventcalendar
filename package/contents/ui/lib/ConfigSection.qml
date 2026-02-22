import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GroupBox {
	id: configSection
	Layout.fillWidth: true
	default property alias _contentChildren: content.data

	contentItem: ColumnLayout {
		id: content
	}
}
