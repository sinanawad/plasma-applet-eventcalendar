import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

import "../lib/Requests.js" as Requests
import ".."
import "../weather/WeatherCanada.js" as WeatherCanada

Window {
	id: chooseCityDialog
	title: i18n("Select city")

	width: 500
	height: 600
	property bool loadingCityList: false
	property bool cityListLoaded: false

	signal accepted()
	signal rejected()

	function open() {
		show()
	}

	ListModel { id: emptyListModel }
	ListModel { id: cityListModel }
	KItemModels.KSortFilterProxyModel {
		id: filteredCityListModel
		// sourceModel: cityListModel // Link after populating cityListModel so the UI doesn't freeze.
		sourceModel: emptyListModel
		filterRoleName: 'name'
		sortRoleName: 'name'
		sortCaseSensitivity: Qt.CaseInsensitive
	}

	property string selectedCityId: ''

	Timer {
		id: debouceApplyFilter
		interval: 1000
		onTriggered: filteredCityListModel.filterString = cityNameInput.text
	}

	onVisibleChanged: {
		if (visible && !cityListLoaded && !loadingCityList) {
			loadProvinceCityList()
		}
	}

	ColumnLayout {
		anchors.fill: parent
		anchors.margins: Kirigami.Units.largeSpacing

		LinkText {
			text: i18n("Fetched from <a href=\"%1\">%1</a>", "https://weather.gc.ca/canada_e.html")
		}

		TabBar {
			id: provinceTabBar
			Layout.fillWidth: true

			Repeater {
				id: provinceRepeater
				model: ['AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT']
				TabButton { text: modelData }
			}

			onCurrentIndexChanged: loadProvinceCityList()
		}

		TextField {
			id: cityNameInput
			Layout.fillWidth: true
			text: ''
			placeholderText: i18n("Search")
			onTextChanged: debouceApplyFilter.restart()
		}
		ScrollView {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumHeight: 200

			ListView {
				id: listView
				clip: true
				model: filteredCityListModel

				header: RowLayout {
					width: listView.width
					spacing: Kirigami.Units.smallSpacing
					Label {
						text: i18n("Name")
						font.bold: true
						Layout.fillWidth: true
						Layout.preferredWidth: 240
					}
					Label {
						text: i18n("Id")
						font.bold: true
						Layout.preferredWidth: 100
					}
					Label {
						text: i18n("City Webpage")
						font.bold: true
						Layout.preferredWidth: 100
					}
				}

				delegate: ItemDelegate {
					width: listView.width
					highlighted: chooseCityDialog.selectedCityId === model.id
					onClicked: chooseCityDialog.selectedCityId = model.id

					contentItem: RowLayout {
						spacing: Kirigami.Units.smallSpacing
						Label {
							text: model.name
							Layout.fillWidth: true
							Layout.preferredWidth: 240
							elide: Text.ElideRight
						}
						Label {
							text: model.id
							Layout.preferredWidth: 100
						}
						LinkText {
							Layout.preferredWidth: 100
							text: '<a href="https://weather.gc.ca/city/pages/' + model.id + '_metric_e.html">' + i18n("Open Link") + '</a>'
						}
					}
				}

				BusyIndicator {
					anchors.centerIn: parent
					running: visible
					visible: chooseCityDialog.loadingCityList
				}
			}
		}

		DialogButtonBox {
			Layout.fillWidth: true
			standardButtons: DialogButtonBox.Ok | DialogButtonBox.Cancel
			onAccepted: {
				chooseCityDialog.accepted()
				chooseCityDialog.close()
			}
			onRejected: {
				chooseCityDialog.selectedCityId = ''
				chooseCityDialog.rejected()
				chooseCityDialog.close()
			}
		}
	}


	function loadCityList(provinceUrl) {
		chooseCityDialog.loadingCityList = true
		filteredCityListModel.sourceModel = emptyListModel
		cityListModel.clear()

		Requests.request(provinceUrl, function(err, data) {
			if (err) {
				console.log('[eventcalendar]', 'loadCityList.err', err, data)
				chooseCityDialog.loadingCityList = false
				return
			}
			var cityList = WeatherCanada.parseProvincePage(data)
			for (var i = 0; i < cityList.length; i++) {
				cityListModel.append(cityList[i])
			}

			// link after populating so that each append() doesn't attempt to rebuild the UI.
			filteredCityListModel.sourceModel = cityListModel

			chooseCityDialog.cityListLoaded = true
			chooseCityDialog.loadingCityList = false
		})
	}

	property alias provinceIdList: provinceRepeater.model
	function loadProvinceCityList() {
		var provinceId = provinceIdList[0]
		if (provinceTabBar.currentIndex >= 0) {
			provinceId = provinceIdList[provinceTabBar.currentIndex]
		}

		var provinceUrl = 'https://weather.gc.ca/forecast/canada/index_e.html?id=' + provinceId
		loadCityList(provinceUrl)
	}
}
