/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import deviceInfo from '@ohos.deviceInfo';
import { CommonConstants as BaseCommon } from '@ohos/base';
import { CommonConstants as Common } from '../constants/CommonConstants';

@Component
export struct CommentBarView {
  @State isMouseClick: boolean = false;
  @State content: string = '';
  isShowInput?: boolean = true;
  jumpDetail: () => void = () => {
  };

  build() {
    Column() {
      Row() {
        if (!this.isMouseClick) {
          Row(){
            Text($r('app.string.detail_write_comment'))
              .fontSize($r('app.float.comment_context_fs'))
              .fontWeight(FontWeight.Normal)
              .fontColor(Color.Black)
              .opacity($r('app.float.comment_context_opacity'))
          }
          .borderRadius($r('app.float.comment_context_br'))
          .backgroundColor($r('app.color.comment_context_bgc'))
          .padding({
            left: $r('app.float.window_padding_left_sm')
          })
          .justifyContent(FlexAlign.Start)
          .height($r('app.float.comment_input_height'))
          .width(Common.COMMENT_BAR_INPUT_WIDTH)
          .margin({ left: Common.COMMENT_BAR_INPUT_ML })
          .visibility(this.isShowInput ? Visibility.Visible : Visibility.None)
          .onMouse((event: MouseEvent) => {
            if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
              this.isMouseClick = true;
            }
          })
          .onClick(() => {
            if (!this.isMouseClick) {
              AppStorage.setOrCreate('isShowInput', true);
            }
          })

          Row() {
            Image($r('app.media.ic_toolbar_comment'))
              .width($r('app.float.toolbar_comment_image_width'))
              .aspectRatio(1)
              .onClick(() => {
                this.jumpDetail();
              })
            Image($r('app.media.ic_toolbar_star'))
              .width($r('app.float.toolbar_comment_image_width'))
              .aspectRatio(1)
            Image($r('app.media.ic_toolbar_heart'))
              .width($r('app.float.toolbar_comment_image_width'))
              .aspectRatio(1)
            Image($r('app.media.ic_toolbar_share'))
              .width($r('app.float.toolbar_comment_image_width'))
              .aspectRatio(1)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.SpaceAround)
        }
        else {
          Row() {
            TextArea({ placeholder: $r('app.string.detail_write_comment'), text: this.content })
              .maxLines(Common.TEXT_AREA_MAX_LINES)
              .constraintSize({
                minHeight: $r('app.float.constraint_size')
              })
              .enableKeyboardOnFocus(true)
              .maxLength(Common.TEXT_AREA_MAX_LENGTH)
              .showCounter(true)
              .layoutWeight(1)

            Image($r('app.media.ic_toolbar_sent'))
              .width($r('app.float.toolbar_sent_width'))
              .aspectRatio(1)
              .margin({
                left: $r('app.float.toolbar_sent_ml'),
                bottom: $r('app.float.toolbar_sent_mb')
              })
              .onClick(() => {
                this.isMouseClick = false;
              })
          }
          .width(BaseCommon.FULL_PERCENT)
          .padding({
            left: $r('app.float.dialog_pl'),
            right: $r('app.float.dialog_pr'),
            top: $r('app.float.dialog_pt'),
            bottom: $r('app.float.dialog_pt')
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom)
          .backgroundColor($r('app.color.white'))
        }
      }
      .width(BaseCommon.FULL_PERCENT)
      .height($r('app.float.toolbar_comment_height'))
      .borderWidth({ top: $r('app.float.comment_bar_border_with') })
      .borderColor($r('app.color.comment_bar_border_color'))
    }
    .width(BaseCommon.FULL_PERCENT)
    .height(this.getColumnHeight())
    .backgroundColor($r('app.color.white'))
  }

  getColumnHeight(): Resource {
    if (deviceInfo.deviceType === BaseCommon.DEVICE_2IN1){
      return $r('app.float.toolbar_comment_height');
    }
    return this.isShowInput ? $r('app.float.toolbar_comment_input_height') : $r('app.float.toolbar_comment_height');
  }
}