/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BreakpointType, BreakpointTypeEnum, WindowUtil } from '@ohos/common';
import { AppConstants } from '../constants/AppConstants';
import { TabBarData, TabBarType, TabsInfo } from '../model/TabBarModel';

@Component
export struct CustomTabBar {
  @Link currentIndex: TabBarType;
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;

  onChange(index: TabBarType): void {
    this.currentIndex = index;
    if (this.currentIndex === TabBarType.MINE) {
      WindowUtil.updateStatusBarColor(getContext(this), true);
    } else {
      WindowUtil.updateStatusBarColor(getContext(this), false);
    }
  }

  build() {
    Flex({
      direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? FlexDirection.Column : FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceAround
    }) {
      ForEach(TabsInfo, (item: TabBarData) => {
        TabItem({
          index: item.id,
          selectedIndex: this.currentIndex,
          onChange: (index: number) => this.onChange(index)
        })
      }, (item: TabBarData) => item.id.toString())
    }
    .backgroundColor($r('app.color.hmos_light_white'))
    .border({
      width: this.currentBreakpoint === BreakpointTypeEnum.LG ? { right: $r('app.float.tab_border_width') } : {
        top: $r('app.float.tab_border_width')
      },
      color: $r('app.color.tab_border_color')
    })
    .padding(this.currentBreakpoint === BreakpointTypeEnum.LG ? {
      top: AppConstants.TAB_PERCENT,
      bottom: AppConstants.TAB_PERCENT
    } : 0)
    .clip(false)
    .height(new BreakpointType<Length>({
      sm: $r('app.float.tool_bar_height'),
      md: $r('app.float.tool_bar_height'),
      lg: AppConstants.FULL_PERCENT
    }).getValue(this.currentBreakpoint))
    .width(new BreakpointType<Length>({
      sm: AppConstants.FULL_PERCENT,
      md: AppConstants.FULL_PERCENT,
      lg: $r('app.float.tool_bar_width')
    }).getValue(this.currentBreakpoint))
  }
}

@Component
struct TabItem {
  @Prop index: number
  @Prop selectedIndex: number;
  onChange: (index: number) => void = () => {
  };

  build() {
    Column() {
      Image(this.selectedIndex === this.index ? TabsInfo[this.index].activeIcon : TabsInfo[this.index].defaultIcon)
        .size(this.index === TabBarType.CHALLENGE ?
          { width: $r('app.float.tab_big_img_width'), height: $r('app.float.tab_big_img_height') } :
          { width: $r('app.float.tab_img_size'), height: $r('app.float.tab_img_size') })
        .margin({ top: this.index === TabBarType.CHALLENGE ? $r('app.float.tab_margin') : 0 })
      Text(TabsInfo[this.index].title)
        .fontSize($r('app.float.tab_font_size'))
        .margin({ top: $r('app.float.tab_title_margin') })
        .fontWeight(AppConstants.TAB_FONT_WEIGHT)
        .fontColor(this.index === this.selectedIndex ? $r('app.color.theme_blue_color') : $r('app.color.tab_bar_color'))
    }
    .clip(false)
    .justifyContent(FlexAlign.Center)
    .onClick(() => this.onChange(this.index))
  }
}