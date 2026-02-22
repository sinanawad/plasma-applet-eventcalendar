import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

Item {
	implicitWidth: label.implicitWidth
	implicitHeight: label.implicitHeight

	property string version: plasmoid.metaData.version ?? "?"

	Text {
		id: label
		text: i18n("<b>Version:</b> %1", version)
		textFormat: Text.StyledText
	}
}
