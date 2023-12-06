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

import router from '@ohos.router';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { AppConstants } from '../constants/AppConstants';
import { BreakpointSystem, BreakpointType, BreakpointTypeEnum } from '@ohos/common';
import { SplashConstants } from '../constants/SplashConstants';

let params: Record<string, Object> = router.getParams() as Record<string, Object>;
let uri: string = params['uri'].toString();
let context = getContext(this) as common.ApplicationContext;
let filesDir = context.cacheDir;
let imageWidth: BreakpointType<Resource> = new BreakpointType<Resource>({
  sm: $r('app.float.image_height'),
  md: $r('app.float.fold_image_width'),
  lg: $r('app.float.edit_image_width')
})
let circleWidth: BreakpointType<CircleOptions> = new BreakpointType<CircleOptions>({
  sm: { height: AppConstants.PHONE_WIDTH, width: AppConstants.PHONE_WIDTH },
  md: { height: AppConstants.FOLD_WIDTH, width: AppConstants.FOLD_WIDTH },
  lg: { height: AppConstants.PAD_WIDTH, width: AppConstants.PAD_WIDTH },
})
let halfImagetop: BreakpointType<Resource> = new BreakpointType<Resource>({
  sm: $r('app.float.safe_logo_sm_md'),
  md: $r('app.float.grid_gutter'),
  lg: $r('app.float.safe_title_line_height')
})

let imageHeight: BreakpointType<Resource> = new BreakpointType<Resource>({
  sm: $r('app.float.phone_image_height'),
  md: $r('app.float.fold_image_height'),
  lg: $r('app.float.pad_image_height')
})

let imagePosy: BreakpointType<Resource> = new BreakpointType<Resource>({
  sm: $r('app.float.phone_image_y'),
  md: $r('app.float.fold_image_y'),
  lg: $r('app.float.pad_image_y')
})

@Entry
@Component
struct ConfirmView {
  @StorageLink('profilePath')
  profilePath: string = '';
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToAppear() {
    this.breakpointSystem.register();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .height($r('app.float.splash_title_text_size'))
          .width($r('app.float.splash_title_text_size'))
          .fillColor(Color.Black)
          .onClick(() => {
            router.back();
          })

        Image($r('app.media.ic_public_ok'))
          .height($r('app.float.splash_title_text_size'))
          .width($r('app.float.splash_title_text_size'))
          .fillColor(Color.Black)
          .onClick(() => {
            let srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
            let destFile = fs.openSync(filesDir + '/profile.jpg', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            fs.copyFileSync(srcFile.fd, destFile.fd);
            fs.closeSync(srcFile);
            fs.closeSync(destFile);
            this.profilePath = filesDir + '/profile.jpg';
            router.back();
          })
      }
      .padding({
        right: $r('app.float.splash_title_text_size'),
        left: $r('app.float.splash_title_text_size'),
        top: $r('app.float.splash_title_text_size')
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .width(AppConstants.FULL_PERCENT)
      .margin({ bottom: halfImagetop.getValue(this.currentBreakpoint), top: $r('app.float.splash_title_text_size') })

      Stack() {
        Image(uri)
          .width(imageWidth.getValue(this.currentBreakpoint))
          .height(imageHeight.getValue(this.currentBreakpoint))
          .mask(new Rect({ width: AppConstants.FULL_PERCENT, height: AppConstants.FULL_PERCENT }).fill(Color.Gray))
        Image(uri)
          .width(imageWidth.getValue(this.currentBreakpoint))
          .height(imageHeight.getValue(this.currentBreakpoint))
          .clip(new Circle(circleWidth.getValue(this.currentBreakpoint)).position({
            y: imagePosy.getValue(this.currentBreakpoint)
          }))
      }
    }
    .backgroundColor(Color.White)
    .height(AppConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
  }
}