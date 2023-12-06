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

import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import webview from '@ohos.web.webview';
import { BreakpointType, BreakpointTypeEnum, LoadingLayout, Logger, WebpageStatus } from '@ohos/common';
import { LearningConstants } from '../constants/LearningConstants';
import { LearningPath } from '../entity/LearningPath';

const TAG = '[LearningDetailPage]';

const LEARN_MIN_DURATION = 5;

@Entry
@Component
struct LearningDetailPage {
  @State learningItem: LearningPath = (router.getParams() as Record<string, LearningPath>)['learningItem'] as LearningPath;
  @State webViewController: webview.WebviewController = new webview.WebviewController();
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @State isLoading: boolean = true;
  @State webStatus: WebpageStatus = WebpageStatus.INIT;
  private intervalId?: number;
  private learnSeconds: number = 0;

  onBackPress() {
    if (this.webViewController.getUrl() !== this.learningItem.url) {
      this.webViewController.backward();
      return true;
    }
    let bundleName = (getContext(this) as common.UIAbilityContext).applicationInfo.name;
    if (this.learningItem.isLearned === false && this.learnSeconds >= LEARN_MIN_DURATION) {
      AppStorage.setOrCreate<boolean>('isLearned', true);
      router.back({
        url: `@bundle:${bundleName}/phone/ets/pages/MainPage`,
        params: { learningId: this.learningItem.id }
      });
    } else {
      router.back();
    }
    return true;
  }

  onPageHide() {
    if (this.intervalId && this.intervalId > -1) {
      clearInterval();
      this.intervalId = undefined;
    }
  }

  startLearning(): void {
    if (!this.intervalId && (!this.learningItem.isLearned)) {
      this.learnSeconds = 0;
      this.intervalId = setInterval(() => {
        this.learnSeconds++;
        Logger.info(TAG, 'learnSeconds: ' + this.learnSeconds);
        if (this.learnSeconds === LEARN_MIN_DURATION) {
          clearInterval(this.intervalId);
          Logger.info(TAG, 'learning completed');
        }
      }, LearningConstants.ANIMATION_DURATION_NORMAL);
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('app.media.ic_back'))
            .width($r('app.float.achieve_close_icon_size'))
            .margin({ left: $r('app.float.navigation_margin'), right: $r('app.float.navigation_margin') })
            .onClick(() => {
              this.onBackPress();
            })
          Text(this.learningItem.title)
            .fontSize($r('app.float.font_size_large'))
        }
        .width(LearningConstants.FULL_PERCENT)
        .height($r('app.float.navigation_height'))

        if (this.webStatus != WebpageStatus.FINISHED) {
          LoadingLayout()
        }
        Web({ controller: this.webViewController, src: this.learningItem.url })
          .darkMode(WebDarkMode.Auto)
          .fileAccess(true)
          .mixedMode(MixedMode.All)
          .cacheMode(CacheMode.None)
          .domStorageAccess(true)
          .zoomAccess(true)
          .javaScriptAccess(true)
          .onErrorReceive((event) => {
            this.webStatus = WebpageStatus.FINISHED
          })
          .onPageBegin(() => {
            this.isLoading = false;
            Logger.info(TAG, 'start loading');
          })
          .onPageEnd(() => {
            Logger.info(TAG, 'loading completed');
            this.webStatus = WebpageStatus.FINISHED
            this.startLearning();
          })
          .width(new BreakpointType({
            sm: LearningConstants.FULL_PERCENT,
            md: LearningConstants.PERCENT_70,
            lg: LearningConstants.PERCENT_64
          }).getValue(this.currentBreakpoint))
          .height(LearningConstants.FULL_PERCENT)
      }
    }
    .padding({ top: AppStorage.get<number>('statusBarHeight') })
    .width(LearningConstants.FULL_PERCENT)
    .height(LearningConstants.FULL_PERCENT)
  }
}