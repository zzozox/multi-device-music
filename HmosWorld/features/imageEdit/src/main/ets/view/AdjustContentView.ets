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

import { BreakpointTypeEnum } from '@ohos/common';
import { adjustIconList, IconStatus } from '../viewModel/IconListViewModel';
import { CommonConstants } from '../common/constant/CommonConstants';
import { AdjustId, IToolsTab } from '../viewModel/OptionViewModel';
import { SliderCustom } from './SliderCustom';

@Component
export default struct AdjustContentView {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @State currentAdjustIndex: number = 0;
  @Consume currentAdjustData: Array<number>;
  AdjustIconList: Array<IconStatus> = adjustIconList;
  tabs: IToolsTab[] = [
    {
      id: AdjustId.BRIGHTNESS,
      value: AdjustId.BRIGHTNESS.valueOf(),
      text: $r('app.string.brightness')
    },
    {
      id: AdjustId.TRANSPARENCY,
      value: AdjustId.TRANSPARENCY.valueOf(),
      text: $r('app.string.transparency')
    },
    {
      id: AdjustId.SATURATION,
      value: AdjustId.SATURATION.valueOf(),
      text: $r('app.string.saturation')
    },
  ];

  @Builder
  TabBuilder(index: number, name: string | Resource) {
    Column() {
      Image(this.currentAdjustIndex === index ? this.AdjustIconList[index]?.chosen : this.AdjustIconList[index]?.normal)
        .width($r('app.float.adjust_icon_width'))
        .height($r('app.float.adjust_icon_height'))

      Text(name)
        .fontColor(this.currentAdjustIndex === index ? $r('app.color.hmos_main_blue_dark') : Color.White)
        .fontSize($r('app.float.adjust_font_size'))
        .margin({ top: $r('app.float.adjust_margin_top') })
    }
    .width($r('app.float.main_page_button_width'))
    .aspectRatio(1)
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      ForEach(this.tabs, (item: IToolsTab) => {
        TabContent() {
          SliderCustom({
            currentIndex: item.value,
            min: CommonConstants.SLIDER_MIN.valueOf(),
            max: CommonConstants.SLIDER_MAX.valueOf(),
            currentAdjustData: $currentAdjustData
          })
        }
        .tabBar(this.TabBuilder(item.id, item.text))
      })
    }
    .vertical(this.currentBreakpoint === BreakpointTypeEnum.LG)
    .height(this.currentBreakpoint === BreakpointTypeEnum.LG ? CommonConstants.LAYOUT_FULL_SCREEN : $r('app.float.tool_width'))
    .width(this.currentBreakpoint === BreakpointTypeEnum.LG ? $r('app.float.tool_width') : CommonConstants.LAYOUT_FULL_SCREEN)
    .onChange((index: number) => {
      this.currentAdjustIndex = index;
    })
  }
}