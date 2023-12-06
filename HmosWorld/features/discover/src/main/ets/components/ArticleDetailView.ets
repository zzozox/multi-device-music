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
  FailureLayout,
  LearningResource,
  LoadingLayout,
  WebpageStatus,
  ObservedArray,
  ResourcesType,
  InteractiveAreaView
} from '@ohos/common';
import { UserModel } from '@ohos/mine';
import { DiscoverModel } from '../model/DiscoverModel';
import { TopNavigationView } from './TopNavigationView';

const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;

@Component
export struct ArticleDetailView {
  onDestinationBack: () => boolean = () => false;
  @Prop articleDetail: LearningResource = new LearningResource();
  @Link webViewController: WebviewController;
  @State userModel: UserModel = UserModel.getInstance();
  @State discoverModel: DiscoverModel = DiscoverModel.getInstance();
  @State collectedIds: ObservedArray<string> = this.userModel.collectedIds;
  @State likedIds: ObservedArray<string> = this.userModel.likedIds;
  @State showInteractiveArea: boolean = true;
  @State webStatus: WebpageStatus = WebpageStatus.INIT;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

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
        TopNavigationView({
          title: this.articleDetail.type === ResourcesType.FEED ? $r('app.string.feed') : $r('app.string.article'),
          onBackClick: this.onDestinationBack
        })
        if (this.webStatus == WebpageStatus.INIT) {
          LoadingLayout()
        }
        Stack() {
          if (this.articleDetail.webUrl?.length > 0) {
            Stack({ alignContent: Alignment.Bottom }) {
              Web({ src: this.articleDetail.webUrl, controller: this.webViewController })
                .darkMode(WebDarkMode.Auto)
                .zoomAccess(true)
                .fileAccess(true)
                .mixedMode(MixedMode.All)
                .cacheMode(CacheMode.None)
                .javaScriptAccess(true)
                .domStorageAccess(true)
                .onErrorReceive((event) => {
                  this.webStatus = WebpageStatus.ERROR
                })
                .onPageEnd(() => {
                  if (this.webStatus != WebpageStatus.ERROR) {
                    this.webStatus = WebpageStatus.FINISHED
                  }
                  if (this.webViewController.accessBackward()) {
                    this.showInteractiveArea = false;
                  } else {
                    this.showInteractiveArea = true;
                  }
                })

              if (this.showInteractiveArea && this.webStatus == WebpageStatus.FINISHED) {
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
                  .margin({ bottom: $r('app.float.top_navigation_height') })
              }
            }
            .width(new BreakpointType({
              sm: CommonConstants.FULL_PERCENT,
              md: CommonConstants.PERCENT_70,
              lg: CommonConstants.PERCENT_64
            }).getValue(this.currentBreakpoint))
          }
          if (this.webStatus === WebpageStatus.ERROR) {
            Column() {
              FailureLayout({ handleReload: () => {
                this.webViewController.loadUrl(this.articleDetail.webUrl)
                this.webStatus = WebpageStatus.INIT
              } })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(Color.White)
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .padding({ bottom: $r('app.float.top_navigation_height') })
          }
        }
      }
      .padding({ top: AppStorage.get<number>('statusBarHeight') })
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onBackPressed(() => this.onDestinationBack())
  }
}