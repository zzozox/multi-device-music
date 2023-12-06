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

import webview from '@ohos.web.webview';
import common from '@ohos.app.ability.common';
import {
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  InteractiveAreaView,
  LearningResource,
  ObservedArray,
  ResourcesType
} from '@ohos/common';
import { UserModel } from '../model/UserModel';

const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;

@Component
export struct ArticleDetailView {
  onDestinationBack: () => boolean = () => false;
  @Link webViewController: WebviewController;
  @State userModel: UserModel = UserModel.getInstance();
  @Prop articleDetail: LearningResource = new LearningResource();
  @Prop isLarge: boolean = false;
  @State collectedIds: ObservedArray<string> = this.userModel.collectedIds;
  @State likedIds: ObservedArray<string> = this.userModel.likedIds;
  @State showInteractiveArea: boolean = true;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @Consume('minePathStack') minePathStack: NavPathStack;

  aboutToAppear() {
    this.webViewController = new webview.WebviewController();
  }

  isCollected(): boolean {
    return this.collectedIds.some((id: string) => id === this.articleDetail.id);
  }

  isLiked(): boolean {
    return this.likedIds.some((id: string) => id === this.articleDetail.id);
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_back'))
              .width($r('app.float.topics_select_width'))
              .margin({ right: $r('app.float.lg_padding_margin_left') })
              .onClick(this.onDestinationBack)
              .visibility(this.currentBreakpoint !== BreakpointTypeEnum.LG || this.isLarge ? Visibility.Visible : Visibility.None)

            Text(this.articleDetail.type === ResourcesType.FEED ? $r('app.string.feed') : $r('app.string.article'))
              .fontSize($r('app.float.nav_title_font_size'))
          }

          Image(this.isLarge ? $r('app.media.ic_reduce') : $r('app.media.ic_enlarge'))
            .height($r('app.float.enlarge_img_size'))
            .aspectRatio(1)
            .onClick(() => {
              if (this.isLarge) {
                this.minePathStack.pop();
              } else {
                this.minePathStack.pushPathByName('detailLarge', this.articleDetail);
              }
            })
            .visibility(this.currentBreakpoint === BreakpointTypeEnum.LG ? Visibility.Visible : Visibility.Hidden)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(this.isLarge ? {
          left: $r('app.float.xxl_padding_margin'),
          right: $r('app.float.xxl_padding_margin')
        } : {
          left: $r('app.float.md_padding_margin'),
          right: $r('app.float.md_padding_margin')
        })
        .height($r('app.float.tab_bar_height'))
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius({ topLeft: $r('app.float.large_border_radius'), topRight: $r('app.float.large_border_radius') })
        .backgroundColor(Color.White)

        Stack({ alignContent: Alignment.Bottom }) {
          Web({ src: this.articleDetail.webUrl, controller: this.webViewController })
            .darkMode(WebDarkMode.Auto)
            .zoomAccess(true)
            .fileAccess(true)
            .mixedMode(MixedMode.All)
            .cacheMode(CacheMode.None)
            .javaScriptAccess(true)
            .domStorageAccess(true)
            .onPageEnd(() => {
              if (this.webViewController.accessBackward()) {
                this.showInteractiveArea = false;
              } else {
                this.showInteractiveArea = true;
              }
            })

          if (this.showInteractiveArea) {
            InteractiveAreaView({
              isLiked: this.isLiked(),
              isCollected: this.isCollected(),
              onCollected: () => {
                eventHub.emit(CommonConstants.COLLECTED_EVENT, {
                  resourceId: this.articleDetail.id,
                  resourceType: this.articleDetail.type,
                  actionValue: !this.isCollected()
                })
              },
              onLiked: () => {
                eventHub.emit(CommonConstants.LIKED_EVENT, {
                  resourceId: this.articleDetail.id,
                  resourceType: this.articleDetail.type,
                  actionValue: !this.isLiked()
                })
              }
            })
          }
        }
        .layoutWeight(1)
        .width(this.isLarge ? new BreakpointType({
          sm: CommonConstants.FULL_PERCENT,
          md: CommonConstants.PERCENT_70,
          lg: CommonConstants.PERCENT_64
        }).getValue(this.currentBreakpoint) : CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor(this.isLarge ? Color.White : $r('app.color.hmos_background_color_white'))
      .padding({ top: AppStorage.get<number>('statusBarHeight') })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ right: !this.isLarge ? $r('app.float.xxl_padding_margin') : 0 })
    .hideTitleBar(true)
    .backgroundColor($r('app.color.hmos_background_color_white'))
    .onBackPressed(() => this.onDestinationBack())
  }
}