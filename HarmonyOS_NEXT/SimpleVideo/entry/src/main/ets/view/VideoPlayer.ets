/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import prompt from '@ohos.promptAction';
import { VideoSlider } from '../view/VideoPlaySlider';
import { prepared, finish, changeSliderTime } from '../model/VideoControll';
import {
  START_TIME,
  STRING_PERCENT,
  COMMON_NUM_DURATION,
  MESSAGE,
  ALL_PERCENT
} from '../common/constants/CommonConstants';
import { ViewPlayerController } from '../controller/ViewPlayerController';

/**
 * video controller component
 */
@Component
export struct VideoPlayer {
  source: string | Resource = '';
  @Consume private vpcontroller : ViewPlayerController;
  private previewUris: Resource = $r('app.media.preview');

  build() {
    Column() {
      Video({
        src: this.source,
        previewUri: this.previewUris,
        controller: this.vpcontroller.controller
      })
        .width(ALL_PERCENT)
        .height(STRING_PERCENT.NINETY_PERCENT)
        .controls(false)
        .autoPlay(false)
        .objectFit(ImageFit.Contain)
        .loop(false)
        .onUpdate((event) => {
          if(event) {
            this.vpcontroller.currentTime = event.time;
            this.vpcontroller.currentStringTime = changeSliderTime(this.vpcontroller.currentTime);
          }
        })
        .onPrepared((event ?: DurationObject) => {
          prepared(this.vpcontroller, event);
        })
        .onFinish(() => {
          finish(this.vpcontroller);
        })
        .onError(() => {
          prompt.showToast({
            duration: COMMON_NUM_DURATION,
            message: MESSAGE
          });
        })
      VideoSlider()
    }
  }
}
export  interface DurationObject {
  duration: number;
}