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
import { BreakpointType, BreakpointTypeEnum, CommonConstants } from '@ohos/common';

@Component
export struct ActivityView {
  activitySrc: string = 'https://developer.huawei.com/consumer/cn/hdc/hdc2023/ticket/101677813051874334/?ha_source=HDCminisite&ha_sourceId=89000360';
  @Link webViewController: WebviewController;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  aboutToAppear() {
    this.webViewController = new webview.WebviewController();
  }

  build() {
    Column() {
      Web({ src: this.activitySrc, controller: this.webViewController })
        .fileAccess(true)
        .mixedMode(MixedMode.All)
        .cacheMode(CacheMode.None)
        .width(new BreakpointType({
          sm: CommonConstants.FULL_PERCENT,
          md: CommonConstants.PERCENT_70,
          lg: CommonConstants.PERCENT_64
        }).getValue(this.currentBreakpoint))
        .javaScriptAccess(true)
        .domStorageAccess(true)
    }
    .padding({ top: AppStorage.get<number>('statusBarHeight') })
    .backgroundColor(Color.White)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}