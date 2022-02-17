/*
 * Copyright (C) 2022 UnionTech Technology Co., Ltd.
 *
 * Author:     xiaoyaobing <xiaoyaobing@uniontech.com>
 *
 * Maintainer: xiaoyaobing <xiaoyaobing@uniontech.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.11
import QtQuick.Shapes 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T
import org.deepin.dtk.impl 1.0 as D
import org.deepin.dtk.style 1.0 as DS

T.Slider {
    id: control

    enum TickPosition {
        NoTicks = 0,
        FrontTick = 1,
        BackTick = 2
    }

    property D.Palette grooveColor: DS.Style.sliderGroove
    property D.Palette tickColor: DS.Style.sliderTick

    property int tickPosition: (Slider.TickPosition.NoTicks)
    property int tickCount: ((to - from) / stepSize)
    property real dashOffset: 0.0
    property var dashPattern: [0.5, 0.25]
    property var tips: []
    property bool highlightPassArea: false
    property bool bothSidesTextHorizontalAlign: true

    readonly property real tickIndex: tickTextIsValid() ? control.position * (tips.length - 1) : 0

    function getSliderHandleType() {
        if (Slider.TickPosition.NoTicks === tickPosition) {
            return control.horizontal ? SliderHandle.HandleType.NoArrowHorizontal : SliderHandle.HandleType.NoArrowVertical
        }

        if (horizontal) {
            if (Slider.TickPosition.FrontTick === tickPosition) {
                return SliderHandle.HandleType.ArrowUp
            } else if (Slider.TickPosition.BackTick === tickPosition) {
                return SliderHandle.HandleType.ArrowBottom
            }
        } else {
            if (Slider.TickPosition.FrontTick === tickPosition) {
                return SliderHandle.HandleType.ArrowLeft
            } else if (Slider.TickPosition.BackTick === tickPosition) {
                return SliderHandle.HandleType.ArrowRight
            }
        }
    }

    function tickTextIsValid() {
        return control.tips.length === control.tickCount && control.tips.length > 0 ? true : false
    }

    function fistTickTextIsValid() {
        return control.tips.length > 0 && control.tips[0]
    }

    implicitWidth:  leftPadding + rightPadding + (control.horizontal ? DS.Style.slider.grooveWidth : (DS.Style.slider.handleHeight
                                                                       + (tickTextIsValid() ? Math.max(verticalRepeater.itemAt(verticalRepeater.count - 1).childrenRect.width, DS.Style.slider.tickHeight)
                                                                      : 0) + (fistTickTextIsValid() ? verticalRepeater.itemAt(verticalRepeater.count - 1).childrenRect.height : 0)))
    implicitHeight: topPadding + bottomPadding + (control.horizontal ? (DS.Style.slider.handleHeight
                                         + (tickTextIsValid() ? DS.Style.slider.tickHeight : 0)
                                         + (fistTickTextIsValid() ? horizontalRepeater.itemAt(horizontalRepeater.count - 1).childrenRect.height : 0))
                                       : DS.Style.slider.grooveWidth)
    opacity: control.D.ColorSelector.controlState === D.DTK.DisabledState ? 0.4 : 1

    // draw handle
    handle: SliderHandle {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width)
                                                     : (Slider.TickPosition.FrontTick === tickPosition && tickTextIsValid() ? control.width - width : 0))
        y: control.topPadding + (control.horizontal ? (Slider.TickPosition.FrontTick === tickPosition && tickTextIsValid() ? control.height - height : 0)
                                                    : control.visualPosition * (control.availableHeight - height))
        width: control.horizontal ? DS.Style.slider.handleWidth : DS.Style.slider.handleHeight
        height: control.horizontal ? DS.Style.slider.handleHeight : DS.Style.slider.handleWidth
        color: control.palette.highlight
        type: getSliderHandleType()
        radius: DS.Style.slider.handleRadius
        palette: D.DTK.makeIconPalette(control.palette)
    }

    // draw panel
    background: Item {
        anchors {
            horizontalCenter: !control.horizontal ? control.handle.horizontalCenter : undefined
            verticalCenter: control.horizontal ? control.handle.verticalCenter : undefined
        }

        implicitWidth: control.horizontal ? DS.Style.slider.sliderWidth : handle.width
        implicitHeight: control.horizontal ? handle.height : DS.Style.slider.sliderHeight

        // draw groove
        Item {
            id: sliderGroove
            x: control.horizontal ? 0 : (parent.width - width) / 2
            y: control.horizontal ? (parent.height - height) / 2 : 0
            width: control.horizontal ? parent.width : DS.Style.slider.grooveHeight
            height: control.horizontal ? DS.Style.slider.grooveHeight : parent.height
            Shape {
                ShapePath {
                    capStyle: ShapePath.FlatCap
                    strokeStyle: ShapePath.DashLine
                    strokeColor: control.D.ColorSelector.grooveColor
                    strokeWidth: control.horizontal ? sliderGroove.height : sliderGroove.width
                    dashOffset: control.dashOffset
                    dashPattern: control.dashPattern
                    startX: control.horizontal ? 0 : sliderGroove.width / 2
                    startY: control.horizontal ? sliderGroove.height / 2 : 0
                    PathLine {
                        x: control.horizontal ? sliderGroove.width : sliderGroove.width / 2
                        y: control.horizontal ? sliderGroove.height / 2 : sliderGroove.height
                    }
                }
            }

            // draw passed groove area
            Loader {
                sourceComponent: highlightPassArea ? passedGroove : undefined
            }

            Component {
                id: passedGroove
                Shape {
                    ShapePath {
                        capStyle: ShapePath.FlatCap
                        strokeStyle: ShapePath.DashLine
                        strokeColor: control.palette.highlight
                        strokeWidth: control.horizontal ? sliderGroove.height : sliderGroove.width
                        dashOffset: 0
                        dashPattern: control.dashPattern
                        startX: control.horizontal ? 0 : sliderGroove.width / 2
                        startY: control.horizontal ? sliderGroove.height / 2 : sliderGroove.height
                        PathLine {
                            x: control.horizontal ? control.handle.x : sliderGroove.width / 2
                            y: control.horizontal ? sliderGroove.height / 2 : control.handle.y + control.handle.height / 2
                        }
                    }

                    Item {
                        id: passItem
                        y: control.horizontal ? -DS.Style.slider.grooveHeight / 2 : control.handle.y + control.handle.height / 2
                        height: control.horizontal ? DS.Style.slider.grooveHeight : sliderGroove.height - control.handle.y - control.handle.height / 2
                        width: control.horizontal ? control.handle.x : DS.Style.slider.grooveHeight
                    }

                    BoxShadow {
                        anchors.fill: passItem
                        shadowBlur: 4
                        shadowOffsetY: 2
                        shadowColor: control.palette.highlight
                        rotation: control.horizontal ? 0 : 180
                        opacity: 0.25
                    }
                }
            }
        }
    }

    // vertical Ticks
    Column {
        x: control.horizontal ? 0 : (Slider.TickPosition.BackTick === control.tickPosition ?
                                         (handle.x + handle.width) : (handle.x - width))
        y: handle.height / 2
        width: !horizontal && tickCount > 0 ? DS.Style.slider.tickHeight : 0
        height: !horizontal && tickCount > 0 ? (background.height - handle.height) : 0
        spacing: tickCount > 1 ? height / (tickCount - 1) - DS.Style.slider.tickWidth : 0
        Repeater {
            id: verticalRepeater
            model: control.horizontal ? 0 : (tickTextIsValid() ? tickCount : 0)
            Rectangle {
                width: DS.Style.slider.tickHeight
                height: DS.Style.slider.tickWidth
                color: control.D.ColorSelector.tickColor

                Loader {
                    anchors {
                        fill: vTickText
                        leftMargin: DS.Style.slider.highlightMargin
                        rightMargin: DS.Style.slider.highlightMargin
                    }
                    sourceComponent: control.tickIndex === tips.length - index - 1 && tips.length > 0 && tips[tips.length - index - 1]
                                                           ? highlightComponent : undefined
                }

                Label {
                    id: vTickText
                    anchors {
                        right: Slider.TickPosition.BackTick === control.tickPosition ? undefined : parent.left
                        rightMargin: Slider.TickPosition.BackTick === control.tickPosition ? undefined : DS.Style.slider.tickTextMargin
                        left: Slider.TickPosition.BackTick === control.tickPosition ? parent.right : undefined
                        leftMargin: Slider.TickPosition.BackTick === control.tickPosition ? DS.Style.slider.tickTextMargin : undefined
                        verticalCenter: parent.verticalCenter
                    }
                    text: tips[tips.length - index - 1]
                    color: control.tickIndex === tips.length - index - 1 ? control.palette.highlightedText : control.palette.windowText
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                }
            }
        }
    }

    // horizontal Ticks
    Row {
        id: horizontalRow
        property real perCellWidth: sliderGroove.width / tickCount

        x: handle.width / 2
        y: control.horizontal ? (Slider.TickPosition.BackTick === control.tickPosition ?
                                     (handle.y + handle.height) : (handle.y - height)) : 0
        width: horizontal && tickCount > 0 ? background.width - handle.width : 0
        height: horizontal && tickCount > 0 ? DS.Style.slider.tickHeight : 0
        spacing: tickCount > 1 ? width / (tickCount - 1) - DS.Style.slider.tickWidth : 0
        Repeater {
            id: horizontalRepeater
            model: control.horizontal ? (tickTextIsValid() ? tickCount : 0) : 0
            Rectangle {
                width: DS.Style.slider.tickWidth
                height: DS.Style.slider.tickHeight
                color: control.D.ColorSelector.tickColor

                Loader {
                    anchors {
                        fill: hTickText
                        leftMargin: DS.Style.slider.highlightMargin
                        rightMargin: DS.Style.slider.highlightMargin
                    }
                    sourceComponent: control.tickIndex === index && tips[index] ? highlightComponent : undefined
                }

                Label {
                    id: hTickText
                    anchors {
                        top: Slider.TickPosition.BackTick === control.tickPosition ? parent.bottom : undefined
                        topMargin: Slider.TickPosition.BackTick === control.tickPosition ? DS.Style.slider.tickTextMargin : undefined
                        bottom: Slider.TickPosition.FrontTick === control.tickPosition ? parent.top : undefined
                        bottomMargin: Slider.TickPosition.FrontTick === control.tickPosition ? DS.Style.slider.tickTextMargin : undefined
                        horizontalCenter: control.bothSidesTextHorizontalAlign ? parent.horizontalCenter
                                                                          : ((index === 0 || index === control.tips.length - 1)
                                                                             ? undefined : parent.horizontalCenter)
                        left: index === 0 && !control.bothSidesTextHorizontalAlign ? parent.left : undefined
                        right: index === control.tips.length - 1 && !control.bothSidesTextHorizontalAlign ? parent.right : undefined
                    }
                    width: bothSidesTextHorizontalAlign ? Math.min(implicitWidth, horizontalRow.perCellWidth)
                                                        : ((index === 0 || index === control.tips.length - 1)
                                                           ? Math.min(implicitWidth, horizontalRow.perCellWidth / 2)
                                                           : Math.min(implicitWidth, horizontalRow.perCellWidth))
                    text: tips[index]
                    elide: control.bothSidesTextHorizontalAlign ? Text.ElideMiddle : ((index === 0 || index === control.tips.length - 1)
                                                                                 ? (index === 0 ? Text.ElideRight: Text.ElideLeft)
                                                                                 : Text.ElideMiddle)
                    color: control.tickIndex === index ? control.palette.highlightedText : control.palette.windowText
                    horizontalAlignment: control.bothSidesTextHorizontalAlign ? Text.AlignHCenter : ((index === 0 || index === control.tips.length - 1)
                                                                                 ? (index === 0 ? Text.AlignLeft: Text.AlignRight)
                                                                                 : Text.AlignHCenter)
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Component {
        id: highlightComponent
        Item {
            BoxShadow {
                anchors.fill: parent
                shadowBlur: 6
                shadowOffsetY: 4
                shadowColor: control.palette.highlight
                cornerRadius: highlightRect.radius
                opacity: 0.3
            }

            Rectangle {
                id: highlightRect
                anchors.fill: parent
                color: control.palette.highlight
                radius: DS.Style.slider.tickRadius
            }

            BoxShadow {
                inner: true
                anchors.fill: parent
                shadowBlur: 2
                shadowOffsetY: -1
                spread: 1
                shadowColor: D.DTK.makeColor(control.palette.highlight).lightness(-20).color()
                cornerRadius: highlightRect.radius
            }
        }
    }
}
