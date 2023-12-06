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

import router from '@ohos.router';
import webview from '@ohos.web.webview';
import { ActivityView } from '@ohos/activity';
import { ArticleDetailView, DiscoverView, FeedList } from '@ohos/discover';
import { LearningView } from '@ohos/learning';
import { ChallengeView } from '@ohos/challenge';
import { BreakpointSystem, BreakpointTypeEnum, LearningResource, Logger, WindowUtil } from '@ohos/common';
import { MineView } from '@ohos/mine';
import { AppConstants } from '../constants/AppConstants';
import { CustomTabBar } from '../components/CustomTabBar';
import { TabBarType } from '../model/TabBarModel';
import image from '@ohos.multimedia.image';

const TAG = '[App]';
/**
 * profile path init;
 */
PersistentStorage.persistProp('profilePath', '');
PersistentStorage.persistProp('showTag', 0);

@Entry
@Component
struct MainPage {
  @State currentIndex: TabBarType = TabBarType.DISCOVER;
  @State webViewController: webview.WebviewController | null = null;
  @State learnedId: string = '';
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Provide('minePathStack') minePathStack: NavPathStack = new NavPathStack();
  @Provide('discoverPathStack') discoverPathStack: NavPathStack = new NavPathStack();
  @StorageLink('profilePath') profilePath: string = '';
  @StorageLink('showTag') showTag: number = 0;

  aboutToAppear() {
    this.breakpointSystem.register();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  onPageShow() {
    if (this.currentIndex === TabBarType.MINE) {
      WindowUtil.updateStatusBarColor(getContext(this), true);
    }
    Logger.info(TAG, 'onPageShow');
    if (AppStorage.get<boolean>('isLearned')) {
      AppStorage.delete('isLearned');
      this.learnedId = router.getParams() ? (router.getParams() as Record<string, string>)['learningId'] : '';
      Logger.info(TAG, `learnedId: ${this.learnedId}`);
    }
    if (AppStorage.get<boolean>('getHomeResource')) {
      this.currentIndex = TabBarType.DISCOVER;
    }
    if (this.profilePath != '') {
      let imageSource: image.ImageSource = image.createImageSource(this.profilePath);
      imageSource.createPixelMap((err, pixelmap) => {
        AppStorage.setOrCreate('pixelmap', pixelmap);
        this.showTag++;
      });
    }
  }

  onBackPress() {
    if (this.webViewController?.accessBackward()) {
      this.webViewController.backward();
      return true;
    }
    return false;
  }

  @Builder
  appRouter(name: string, param: object) {
    if (name === 'articleDetail') {
      ArticleDetailView({
        articleDetail: param as LearningResource,
        webViewController: $webViewController,
        onDestinationBack: () => this.onDestinationBack()
      })
    } else if (name === 'feedList') {
      FeedList({
        onDestinationBack: () => this.appPathStack.pop()
      })
    }
  }

  onDestinationBack(): boolean {
    if (this.webViewController?.accessBackward()) {
      this.webViewController.backward();
    } else {
      if (this.currentIndex === TabBarType.MINE) {
        WindowUtil.updateStatusBarColor(getContext(this), true);
      }
      this.appPathStack.pop();
    }
    return true;
  }

  build() {
    Navigation(this.appPathStack) {
      Flex({
        direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? FlexDirection.RowReverse : FlexDirection.Column,
      }) {
        Tabs({ index: this.currentIndex }) {
          TabContent() {
            DiscoverView()
          }

          TabContent() {
            LearningView({ learnedId: this.learnedId })
          }

          TabContent() {
            ChallengeView()
          }

          TabContent() {
            ActivityView({ webViewController: $webViewController })
          }

          TabContent() {
            MineView()
          }
        }
        .layoutWeight(1)
        .backgroundColor($r('app.color.common_background_color'))
        .barHeight(0)
        .scrollable(false)
        .onChange((index) => {
          this.currentIndex = index;
        })

        CustomTabBar({ currentIndex: $currentIndex })
      }
      .width(AppConstants.FULL_PERCENT)
      .height(AppConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .navDestination(this.appRouter)
    .mode(NavigationMode.Stack)
  }
}