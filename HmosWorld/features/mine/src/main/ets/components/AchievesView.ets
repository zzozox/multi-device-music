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

import { BreakpointType, BreakpointTypeEnum, CommonConstants, ObservedArray } from '@ohos/common';
import Constants from '../constants/Constants';
import { UserModel } from '../model/UserModel';
import { AchieveImage, ACHIEVE_IMAGE_LIST } from '../model/AchievementModel';
import lottie from '@ohos/lottie';

@Component
export struct AchievesView {
  @State userModel: UserModel = UserModel.getInstance();
  @State learnedIds: ObservedArray<string> = this.userModel.learnedIds;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @State isShow:boolean = false;
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private mainCanvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.mainRenderingSettings)
  @State clickedItem: AchieveImage | null = null;

  aboutToAppear() {
    this.userModel.getUserAchievements();
  }

  getShowImg(item: AchieveImage): Resource | undefined {
    if (this.learnedIds.includes(item.pathId)) {
      return item.activeImage;
    }
    return item.defaultImage;
  }

  build() {
    Column() {
      Text($r('app.string.total_achieve_count', this.learnedIds.length))
        .fontSize($r('app.float.default_font_size'))
        .width(Constants.FULL_SCREEN)
        .fontWeight(FontWeight.Medium)
        .fontFamily(CommonConstants.HARMONY_HEITI_MEDIUM_FONT_FAMILY)
        .padding({
          left: $r('app.float.achievements_count_padding_left'),
          top: $r('app.float.achievements_count_padding_top'),
          bottom: $r('app.float.achievements_count_padding_bottom')
        })
        .textAlign(TextAlign.Start)

      List({ space: Constants.MIDDLE_SPACE }) {
        ForEach(ACHIEVE_IMAGE_LIST, (item: AchieveImage) => {
          ListItem() {
            Image(this.getShowImg(item))
              .interpolation(ImageInterpolation.High)
              .width(new BreakpointType({
                sm: $r('app.float.achievement_image_size_sm'),
                md: $r('app.float.achievement_image_size_md'),
                lg: $r('app.float.achievement_image_size_lg')
              }).getValue(this.currentBreakpoint))
              .aspectRatio(1)
          }
          .padding({
            left: $r('app.float.achievement_list_padding_left_right'),
            right: $r('app.float.achievement_list_padding_left_right'),
            bottom: $r('app.float.achievement_list_padding'),
            top: $r('app.float.achievement_list_padding') })
          .onClick(() => {
            if (this.learnedIds.includes(item.pathId)) {
              lottie.loadAnimation({
                container: this.mainCanvasRenderingContext,
                renderer: 'canvas',
                loop: false,
                autoplay: false,
                name: item.pathId,
                path: item.lottiePath
              });
              lottie.play();
              this.clickedItem = item;
              this.isShow = true;
            }
          })
        }, (item: AchieveImage) => JSON.stringify(item))
      }
      .alignListItem(ListItemAlign.Center)
      .lanes(new BreakpointType({
        sm: Constants.ACHIEVEMENT_LIST_LANES_SM,
        md: Constants.ACHIEVEMENT_LIST_LANES_MD,
        lg: Constants.ACHIEVEMENT_LIST_LANES_LG
      }).getValue(this.currentBreakpoint))
      .width(Constants.FULL_SCREEN)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .bindContentCover(
        this.isShow,
        this.playLottieBuilder(),
        {
          modalTransition: ModalTransition.ALPHA,
          backgroundColor: $r('app.color.achieve_background_color'),
          onDisappear: () => {
            lottie.destroy();
          }
        }
      )
    }
    .height(Constants.FULL_SCREEN)
    .width(Constants.FULL_SCREEN)
    .padding({
      left: $r('app.float.mine_page_padding'),
      right: $r('app.float.mine_page_padding')
    })
  }

  @Builder playLottieBuilder() {
    Column() {
      Column() {
        Canvas(this.mainCanvasRenderingContext)
          .height(Constants.PERCENT_50)
          .width(Constants.PERCENT_80)
          .backgroundColor($r('app.color.achieve_background_color'))
          .onReady(() => {
            if (this.clickedItem != null) {
              lottie.loadAnimation({
                container: this.mainCanvasRenderingContext,
                renderer: 'canvas',
                loop: false,
                autoplay: true,
                name: this.clickedItem.pathId,
                path: this.clickedItem.lottiePath
              })
            }
          })
          .onClick(() => {
            this.isShow = false;
          })
      }
      Column() {
        Button($r('app.string.achieves_button'))
          .onClick(() => {
            this.isShow = false;
          })
      }
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.achieve_background_color'))
    .width(Constants.FULL_SCREEN)
    .height(Constants.FULL_SCREEN)
  }
}