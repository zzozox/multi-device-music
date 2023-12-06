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

import image from '@ohos.multimedia.image';
import promptAction from '@ohos.promptAction'
import router from '@ohos.router';
import { BreakpointTypeEnum, WindowUtil } from '@ohos/common';
import AdjustContentView from '../view/AdjustContentView';
import { encode } from '../utils/EncodeUtil';
import getPixelMap from '../utils/DecodeUtil';
import { CommonConstants } from '../common/constant/CommonConstants';

@Entry
@Component
struct HomePage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @Provide pixelMap?: image.PixelMap = undefined;
  @Provide currentAdjustData: Array<number> = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
  @Provide isPixelMapChange: boolean = false;
  private imageItem?: Resource = undefined;


  onPageShow() {
    WindowUtil.updateStatusBarColor(getContext(this), true);
  }

  onPageHide() {
    WindowUtil.updateStatusBarColor(getContext(this), false);
  }

  flushPixelMapNew() {
    this.isPixelMapChange = !this.isPixelMapChange;
  }

  pixelInit(image: Resource) {
    getPixelMap(image).then((pixelMap?: image.PixelMap) => {
      if (pixelMap) {
        this.isPixelMapChange = !this.isPixelMapChange;
        this.pixelMap = pixelMap;
      }
      this.currentAdjustData = CommonConstants.ADJUST_SLIDER_VALUE.map((item: number) => item);
    })
  }

  aboutToAppear() {
    this.imageItem = (router.getParams() as Record<string, Resource>)['imageItem'];
    this.pixelInit(this.imageItem);
  }

  build() {
    Column() {
      Row() {
        Row() {
          Button() {
            Image($r("app.media.ic_public_back"))
              .width($r('app.float.title_image_width'))
              .height($r('app.float.title_image_height'))
          }
          .height($r('app.float.main_page_button_width'))
          .type(ButtonType.Normal)
          .aspectRatio(1)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back();
          })

          Text($r('app.string.image_edit'))
            .fontColor(Color.White)
            .fontSize($r('app.float.title_font_size'))
            .margin({
              left: $r('app.float.lg_padding_margin')
            })
        }

        Row() {
          Button({ type: ButtonType.Normal }) {
            Image($r("app.media.ic_reset"))
              .width($r('app.float.title_image_width'))
              .height($r('app.float.title_image_height'))
          }
          .height($r('app.float.main_page_button_width'))
          .aspectRatio(1)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.pixelInit(this.imageItem);
          })

          SaveButton({ icon: SaveIconStyle.FULL_FILLED })
            .iconColor(Color.White)
            .iconSize($r('app.float.title_image_height'))
            .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
              if (result == SaveButtonOnClickResult.SUCCESS && this.pixelMap) {
                encode(this, this.pixelMap).then(res => {
                  promptAction.showToast({
                    message: res,
                    duration: CommonConstants.TOAST_DURATION,
                  });
                })
              }
            })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.LAYOUT_FULL_SCREEN)
      .padding({ left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin') })
      .height($r('app.float.title_height'))

      Flex({
        direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? FlexDirection.Row : FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Center
      }) {
        if (this.isPixelMapChange) {
          Image(this.pixelMap ? this.pixelMap : '')
            .objectFit(ImageFit.Contain)
        } else {
          Image(this.pixelMap ? this.pixelMap : '')
            .objectFit(ImageFit.Contain)
        }

        AdjustContentView()
      }
      .padding({ left: this.currentBreakpoint === BreakpointTypeEnum.LG ? $r('app.float.tool_width') : 0 })
      .margin(this.currentBreakpoint === BreakpointTypeEnum.LG ? {
        left: $r('app.float.xxl_padding_margin'),
        right: $r('app.float.xxl_padding_margin')
      } : {
        bottom: $r('app.float.md_padding_margin')
      })
      .layoutWeight(1)
    }
    .width(CommonConstants.LAYOUT_FULL_SCREEN)
    .height(CommonConstants.LAYOUT_FULL_SCREEN)
    .padding({top: AppStorage.get<number>('statusBarHeight')})
    .backgroundColor(Color.Black)
  }
}