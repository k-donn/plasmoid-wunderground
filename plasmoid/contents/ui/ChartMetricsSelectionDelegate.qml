/*
 * Copyright 2022  Rafal (Raf) Liwoch
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../code/utils.js" as Utils

            Component {
                id: chartMetricsSelectionDelegate
                Column {
                    PlasmaCore.SvgItem {
                        id: iconHolder

                        svg: PlasmaCore.Svg {
                            id: iconSvg
                            imagePath: plasmoid.file("", "icons/fullRepresentation/" + dictVals[availableReadings[index]].icon)
                        }

                        Layout.minimumWidth: units.gridUnit * 2
                        Layout.minimumHeight: units.gridUnit * 2
                        width: Layout.minimumWidth
                        height: Layout.minimumHeight

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                iconsListView.currentIndex = index
                                //console.log(icon)
                            }
                            onPressed: {
                                currentLegendText = availableReadings[index];
                                lineChart.nameSource.value = currentLegendText

                                if(staticRange.includes(currentLegendText)) {
                                    lineChart.yRange.automatic = false
                                    lineChart.yRange.from = 0
                                    lineChart.yRange.to = 100
                                } else if(currentLegendText == "pressure") {
                                    var pressureUnit = Utils.currentPresUnit("", false);
                                    lineChart.yRange.automatic = false
                                    lineChart.yRange.from = pressureUnit == "hPa" ? 970 : Math.floor(970*0.03)
                                    lineChart.yRange.to = pressureUnit == "hPa" ? 1040 : Math.floor(1040*0.03)
                                } else {
                                    lineChart.yRange.automatic = true
                                }
                                lineChart.valueSources[0].roleName = currentLegendText
                            }
                        }
                    }
                }
            }