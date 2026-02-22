import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

import org.kde.plasma.private.digitalclock as DigitalClock

import ".."
import "../lib"

// Mostly copied from digitalclock
KCMUtils.SimpleKCM {
	id: page

	function digitalclock_i18n(message) {
		return i18nd("plasma_applet_org.kde.plasma.digitalclock", message)
	}

	DigitalClock.TimeZoneModel {
		id: timeZoneModel

		selectedTimeZones: plasmoid.configuration.selectedTimeZones
		onSelectedTimeZonesChanged: plasmoid.configuration.selectedTimeZones = selectedTimeZones
	}

	DigitalClock.TimeZoneFilterProxy {
		id: filterModel
		sourceModel: timeZoneModel
		filterString: filter.text
	}

	MessageWidget {
		id: messageWidget
	}

	TextField {
		id: filter
		Layout.fillWidth: true
		placeholderText: digitalclock_i18n("Search Time Zones")
	}

	ScrollView {
		Layout.fillWidth: true
		Layout.fillHeight: true

		ListView {
			id: timeZoneView
			clip: true

			model: filterModel

			header: RowLayout {
				width: timeZoneView.width
				spacing: Kirigami.Units.smallSpacing

				Label {
					text: digitalclock_i18n("City")
					font.bold: true
					Layout.fillWidth: true
					Layout.preferredWidth: 150
				}
				Label {
					text: digitalclock_i18n("Region")
					font.bold: true
					Layout.fillWidth: true
					Layout.preferredWidth: 150
				}
				Label {
					text: digitalclock_i18n("Comment")
					font.bold: true
					Layout.fillWidth: true
					Layout.preferredWidth: 150
				}
				Label {
					text: i18n("Tooltip")
					font.bold: true
					Layout.preferredWidth: 80
					horizontalAlignment: Text.AlignHCenter
				}
			}

			delegate: RowLayout {
				width: timeZoneView.width
				spacing: Kirigami.Units.smallSpacing

				Label {
					text: model.city
					Layout.fillWidth: true
					Layout.preferredWidth: 150
					elide: Text.ElideRight
				}
				Label {
					text: model.region
					Layout.fillWidth: true
					Layout.preferredWidth: 150
					elide: Text.ElideRight
				}
				Label {
					text: model.comment
					Layout.fillWidth: true
					Layout.preferredWidth: 150
					elide: Text.ElideRight
				}
				CheckBox {
					Layout.preferredWidth: 80
					Layout.alignment: Qt.AlignHCenter
					checked: model.checked

					onClicked: {
						if (!checked && model.region == "Local") {
							messageWidget.warn(i18n("Cannot deselect Local time from the tooltip"))
							checked = Qt.binding(function(){ return model.checked })
						} else {
							model.checked = checked
						}
					}
				}
			}
		}
	}


	ButtonGroup { id: timezoneDisplayType }
	RowLayout {
		Label {
			text: digitalclock_i18n("Display time zone as:")
		}

		RadioButton {
			id: timezoneCityRadio
			text: digitalclock_i18n("Time zone city")
			ButtonGroup.group: timezoneDisplayType
			checked: !plasmoid.configuration.displayTimezoneAsCode
			onClicked: plasmoid.configuration.displayTimezoneAsCode = false
		}

		RadioButton {
			id: timezoneCodeRadio
			text: digitalclock_i18n("Time zone code")
			ButtonGroup.group: timezoneDisplayType
			checked: plasmoid.configuration.displayTimezoneAsCode
			onClicked: plasmoid.configuration.displayTimezoneAsCode = true
		}
	}
}
